//
//  UIColor+Util.swift
//  Memo
//
//  Created by any on 8/25/25.
//

import Foundation
import UIKit

extension UIColor {
  var data: Data? {
    try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
  }
}
