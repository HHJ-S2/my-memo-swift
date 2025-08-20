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
  private init() {} // 외부에서 생성하지 못하도록 private 키워드 추가
  
  // Context 접근용
  var mainContext: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "Memo")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
          if let error = error as NSError? {
              fatalError("Unresolved error \(error), \(error.userInfo)")
          }
      })
      return container
  }()

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
}
