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
  
  // 데이터 추가시
  public override func validateForInsert() throws {
    try super.validateForInsert()
  }
  
  // 함수 내부에서 값 변경 금지
  @objc func validateContent(_ value: AutoreleasingUnsafeMutablePointer<AnyObject>) throws {
    // 저장된 값 가져오기
    guard let contentValue = value.pointee as? String else {
      return
    }
    
    // 욕설 포함시 에러 throw
    if contentValue.contains("ㅅㅂ") {
      let message = "바른말 사용"
      let code = NSValidationBadWordError
      let error = NSError(domain: NSCocoaErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
      
      throw error
    }
  }
}

public let NSValidationBadWordError = Int.max - 100
