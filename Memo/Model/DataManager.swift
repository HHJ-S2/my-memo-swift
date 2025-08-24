//
//  DataManager.swift
//  Memo
//
//  Created by any on 8/20/25.
//

import Foundation
import CoreData

class DataManager {
  // 싱글톤
  static let shared = DataManager()
  
  let persistentContainer: NSPersistentContainer
  
  let mainContext: NSManagedObjectContext
  
  let memoFetchedResults: NSFetchedResultsController<MemoEntity>
  
  let groupFetchedResults: NSFetchedResultsController<GroupEntity>
  
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
  
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func insertDummyData() {
    #if DEBUG
    let countRequest = MemoEntity.fetchRequest()
    
    do {
      let count = try mainContext.count(for: countRequest)
      
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
      
      print(insertRequest)
      
      // Batch insert - 여러개의 데이터를 한번에 처리
      if let result = try mainContext.execute(insertRequest) as? NSBatchInsertResult, let succeeded = result.result as? Bool {
        if succeeded {
          print("Batch insert success")
        } else {
          print("Batch insert fail")
        }
      }
      
      let groupList: [[String: Any]] = [
        ["name": "일상"],
        ["name": "업무"],
        ["name": "공부"],
        ["name": "쇼핑"],
        ["name": "기타"]
      ]
      
      let groupInsertRequest = NSBatchInsertRequest(entityName: "Group", objects: groupList)
      
      if let result = try mainContext.execute(groupInsertRequest) as? NSBatchInsertResult, let succeeded = result.result as? Bool {
        if succeeded {
          print("Group Batch insert success")
        } else {
          print("Group Batch insert fail")
        }
      }
      
      // saveContext()
      
      try groupFetchedResults.performFetch()
      try memoFetchedResults.performFetch()
    } catch {
      print(error)
    }
    #endif
  }
  
  // 메모 목록 패칭
  func fetch(group: GroupEntity?, keyword: String? = nil) {
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
  
  func insert(memo: String, to group: GroupEntity?) {
    let newMemo = MemoEntity(context: mainContext) // context에 자동으로 insert 됨
    
    newMemo.content = memo
    newMemo.insertDate = .now
    newMemo.group = group
    
    saveContext()
    // list.insert(newMemo, at: 0) // 메모 목록에 추가
  }
  
  func update(entity: MemoEntity, content: String) {
    entity.content = content
    saveContext()
  }
  
  // return 값 사용하지 않았을때 경고 표시 해제
  // @discardableResult
  func delete(entity: MemoEntity) {
    mainContext.delete(entity) // context에 자동으로 delete 됨
    saveContext()
    
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
}
