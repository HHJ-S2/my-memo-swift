//
//  ColorTransformer.swift
//  Memo
//
//  Created by any on 8/25/25.
//

import UIKit

// CoreData의 Transformable 타입의 backgroundColor 속성 저장시 사용
class ColorTransformer: NSSecureUnarchiveFromDataTransformer {
  override class var allowedTopLevelClasses: [AnyClass] {
    return [TransformableColor.self]
  }
}

public class TransformableColor: UIColor {}
