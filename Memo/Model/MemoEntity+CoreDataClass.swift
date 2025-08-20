//
//  MemoEntity+CoreDataClass.swift
//  Memo
//
//  Created by any on 8/20/25.
//
//

import Foundation
import CoreData

fileprivate let formatter: DateFormatter = {
  let formatter = DateFormatter()
  
  formatter.dateStyle = .medium
  formatter.timeStyle = .none
  formatter.doesRelativeDateFormatting = true
  
  return formatter
}()

@objc(MemoEntity)
public class MemoEntity: NSManagedObject {

  var dateString: String? {
    return formatter.string(for: insertDate)
  }
}
