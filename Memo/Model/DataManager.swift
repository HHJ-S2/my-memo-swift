//
//  DataManager.swift
//  Memo
//
//  Created by any on 8/20/25.
//

import Foundation
import CoreData
import UIKit

extension Notification.Name {
  static let ungroupedInfoDidUpdate = Notification.Name("ungroupedInfoDidUpdate")
}

class DataManager {
  // 싱글톤
  static let shared = DataManager()
  
  let persistentContainer: NSPersistentContainer
  
  let mainContext: NSManagedObjectContext
  
  let memoFetchedResults: NSFetchedResultsController<MemoEntity>
  
  let groupFetchedResults: NSFetchedResultsController<GroupEntity>
  
  let backgroundContext: NSManagedObjectContext
  
  var ungroupedMemoCount = 0
  
  var ungroupedLastUpdate: Date? {
    get {
      UserDefaults.standard.object(forKey: "ungroupedLastUpdate") as? Date
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "ungroupedLastUpdate")
    }
  }
  
  // 외부에서 생성하지 못하도록 private 키워드 추가
  private init() {
    let container = NSPersistentContainer(name: "Memo")
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    
    persistentContainer = container
    mainContext = persistentContainer.viewContext
    mainContext.undoManager = UndoManager() // 작업 취소
    
    // backgroundContext 직접 생성
    backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    backgroundContext.parent = mainContext
    
    let request = MemoEntity.fetchRequest()
    let sortByDateDesc = NSSortDescriptor(keyPath: \MemoEntity.insertDate, ascending: false)
    
    request.sortDescriptors = [sortByDateDesc]
    
    memoFetchedResults = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
    
    let groupRequest = GroupEntity.fetchRequest()
    let sortByName = NSSortDescriptor(keyPath: \GroupEntity.title, ascending: true)
    
    groupRequest.sortDescriptors = [sortByName]
    
    groupFetchedResults = NSFetchedResultsController(fetchRequest: groupRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: "MemoGroupCache")
    
    do {
      try memoFetchedResults.performFetch()
      try groupFetchedResults.performFetch()
    } catch {
      print(error)
    }
    
    updateUngroupedInfo()
  }
  
  /**
   // Context 접근용
   var mainContext: NSManagedObjectContext {
   return persistentContainer.viewContext
   }
   */
  
  // 메모 목록
  // var list = [MemoEntity]()
  
  // MARK: - Core Data stack
  
  /**
   lazy var persistentContainer: NSPersistentContainer = {
   
   let container = NSPersistentContainer(name: "Memo")
   container.loadPersistentStores(completionHandler: { (storeDescription, error) in
   if let error = error as NSError? {
   fatalError("Unresolved error \(error), \(error.userInfo)")
   }
   })
   return container
   
   }()
   */
  
  // MARK: - Core Data Saving support
  
  func saveContext (context: NSManagedObjectContext) { // context를 파라미터로 전달받아서 실행
    context.perform { [self] in
      if context.hasChanges {
        do {
          try context.save()
          
          if let parent = context.parent {
            parent.perform {
              do {
                try parent.save()
              } catch {
                let nserror = error as NSError
                
                print("Unresolved error \(nserror), \(nserror.userInfo)")
              }
            }
          }
        } catch {
          let nserror = error as NSError
          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        updateUngroupedInfo()
      }
    }
  }
  
  func insertDummyData() {
#if DEBUG
    // 백그라운드 스레드에서 새로운 컨텍스트를 만들어서 실행
    persistentContainer.performBackgroundTask { (context) in
      
      let countRequest = MemoEntity.fetchRequest()
      
      do {
        let count = try context.count(for: countRequest)
        
        if count > 0 { return }
      } catch {
        print(error)
      }
      
      guard let path = Bundle.main.path(forResource: "lipsum", ofType: "txt") else { return } // 파일 경로
      
      do {
        let source = try String(contentsOfFile: path) // 더미데이터 문자열
        
        let sentences = source.components(separatedBy: .newlines).filter { str in
          str.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 // 공백, 줄바꿈 제거
        }
        
        var dataList = [[String: Any]]()
        
        for sentence in sentences {
          /**
           let memo = MemoEntity(context: mainContext) // Entity 인스턴스 생성
           memo.content = sentence
           
           // 랜덤 날짜 생성 - 현재날짜 기준 -30
           let randomDate = Date(timeIntervalSinceNow: Double.random(in: 0 ... 3600 * 24 * 30) * -1)
           memo.insertDate = randomDate
           */
          
          dataList.append(["content": sentence, "insertDate": Date(timeIntervalSinceNow: Double.random(in: 0 ... 3600 * 24 * 30) * -1)])
        }
        
        let insertRequest = NSBatchInsertRequest(entityName: "Memo", objects: dataList)
        
        insertRequest.resultType = .objectIDs
        
        // Batch insert - 여러개의 데이터를 한번에 처리
        if let result = try context.execute(insertRequest) as? NSBatchInsertResult,
           let list = result.result as? [NSManagedObjectID], !list.isEmpty
        {
          print("Batch insert success")
          
          let dict = [NSInsertedObjectsKey: list]
          
          // background context에 추가한 Entity 동기화
          NSManagedObjectContext.mergeChanges(fromRemoteContextSave: dict, into: [self.mainContext])
        } else {
          print("Batch insert fail")
        }
        
        let groupList: [[String: Any]] = [
          ["title": "일상"],
          ["title": "업무"],
          ["title": "공부"],
          ["title": "쇼핑"],
          ["title": "기타"]
        ]
        
        let groupInsertRequest = NSBatchInsertRequest(entityName: "Group", objects: groupList)
        
        // 리턴타입을 변경
        groupInsertRequest.resultType = .objectIDs
        
        if let result = try context.execute(groupInsertRequest) as? NSBatchInsertResult,
           let list = result.result as? [NSManagedObjectID],
           !list.isEmpty
        {
          print("Group Batch insert success")
          
          let dict = [NSInsertedObjectsKey: list]
          
          NSManagedObjectContext.mergeChanges(fromRemoteContextSave: dict, into: [self.mainContext])
        } else {
          print("Group Batch insert fail")
        }
        
        self.updateUngroupedInfo()
      } catch {
        print(error)
      }
    }
#endif
  }
  
  // 메모 목록 패칭
  func fetch(group: GroupEntity?, keyword: String? = nil) {
    mainContext.perform { [self] in
      memoFetchedResults.fetchRequest.predicate = nil
      
      if let group {
        if let keyword {
          let predicate = NSPredicate(format: "%K == %@ AND %K CONTAINS [c] %@", #keyPath(MemoEntity.group), group, #keyPath(MemoEntity.content), keyword)
          memoFetchedResults.fetchRequest.predicate = predicate
        } else {
          print("no keyword")
          let predicate = NSPredicate(format: "%K == %@", #keyPath(MemoEntity.group), group)
          memoFetchedResults.fetchRequest.predicate = predicate
        }
      } else {
        if let keyword {
          let predicate = NSPredicate(format: "%K == NIL AND %K CONTAINS [c] %@", #keyPath(MemoEntity.group), #keyPath(MemoEntity.content), keyword)
          memoFetchedResults.fetchRequest.predicate = predicate
        } else {
          print("no group no keyword")
          let predicate = NSPredicate(format: "%K == NIL", #keyPath(MemoEntity.group))
          memoFetchedResults.fetchRequest.predicate = predicate
        }
      }
      
      do {
        try memoFetchedResults.performFetch()
      } catch {
        print(error)
      }
    }
  }
  
  func insert(memo: String, to group: GroupEntity?) throws {
    try mainContext.performAndWait { [self] in
      let newMemo = MemoEntity(context: mainContext) // context에 자동으로 insert 됨
      
      newMemo.content = memo
      newMemo.insertDate = .now
      newMemo.group = group
      // list.insert(newMemo, at: 0) // 메모 목록에 추가
      
      do {
        try newMemo.validateForInsert()
        saveContext(context: mainContext)
      } catch let error as NSError {
        mainContext.rollback()
        throw error.localizedDescription
      } catch {
        print(error)
        mainContext.rollback()
      }
    }
  }
  
  func update(entity: MemoEntity, content: String) {
    mainContext.perform { [self] in
      entity.content = content
      saveContext(context: mainContext)
    }
  }
  
  // return 값 사용하지 않았을때 경고 표시 해제
  // @discardableResult
  func delete(entity: NSManagedObject) {
    let id = entity.objectID
    
    backgroundContext.perform { [self] in
      let target = backgroundContext.object(with: id)
      
      // 메모 or 그룹 삭제
      backgroundContext.delete(target) // context에 자동으로 delete 됨
      saveContext(context: backgroundContext)
    }
    
    // 메모 목록에서 삭제
    // if let index = list.firstIndex(of: entity) {
    //   list.remove(at: index)
    //   return index
    // }
    
    // return nil
  }
  
  func delete(at indexPath: IndexPath) {
    // let target = list[index]
    let target = memoFetchedResults.object(at: indexPath)
    
    delete(entity: target)
  }
  
  // 그룹없는 메모 관련 업데이트
  func updateUngroupedInfo() {
    // mainContext에서 실행하도록
    mainContext.perform { [self] in
      let request = MemoEntity.fetchRequest()
      
      request.predicate = NSPredicate(format: "%K == NIL", #keyPath(MemoEntity.group))
      
      do {
        ungroupedMemoCount = try mainContext.count(for: request)
      } catch {
        print(error)
      }
      
      NotificationCenter.default.post(name: .ungroupedInfoDidUpdate, object: nil)
    }
  }
  
  // 그룹 추가
  func insert(group: String, backgroundColor: UIColor?) throws {
    try mainContext.performAndWait { [self] in
      let newGroup = GroupEntity(context: mainContext)
      
      newGroup.title = group
      
      if let backgroundColor {
        newGroup.backgroundColor = TransformableColor(cgColor: backgroundColor.cgColor)
      }
      
      do {
        try newGroup.validateForInsert()
        saveContext(context: mainContext)
      } catch let error as NSError {
        mainContext.rollback() // 문제가 생긴 context 롤백
        
        switch error.code {
        case NSValidationStringTooShortError, NSValidationStringTooLongError:
          if let attr = error.userInfo[NSValidationKeyErrorKey] as? String, attr == "title" {
            throw "그룹 이름은 2~10자 사이로 입력해주세요"
          } else {
            throw error.localizedDescription
          }
          
        default:
          throw error.localizedDescription
        }
      } catch {
        print(error)
        mainContext.rollback()
      }
    }
  }
  
  // 그룹 수정
  func update(group: GroupEntity, name: String, backgroundColor: UIColor?) throws {
    try mainContext.performAndWait { [self] in
      
      group.title = name
      
      if let backgroundColor {
        group.backgroundColor = TransformableColor(cgColor: backgroundColor.cgColor)
      }
      
      do {
        try group.validateForUpdate()
        saveContext(context: mainContext)
      } catch let error as NSError {
        mainContext.rollback()
        
        switch error.code {
        case NSValidationStringTooShortError, NSValidationStringTooLongError:
          if let attr = error.userInfo[NSValidationKeyErrorKey] as? String, attr == "title" {
            throw "그룹 이름은 2~10자 사이로 입력해주세요"
          } else {
            throw error.localizedDescription
          }
          
        default:
          throw error.localizedDescription
        }
      } catch {
        print(error)
        mainContext.rollback()
      }
    }
  }
}
