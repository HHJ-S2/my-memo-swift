//
//  MemoEntity+CoreDataProperties.swift
//  Memo
//
//  Created by any on 8/20/25.
//
//

import Foundation
import CoreData


extension MemoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoEntity> {
        return NSFetchRequest<MemoEntity>(entityName: "Memo")
    }

    @NSManaged public var content: String?
    @NSManaged public var insertDate: Date?

}

extension MemoEntity : Identifiable {

}
