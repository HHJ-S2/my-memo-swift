//
//  Data+Util.swift
//  Memo
//
//  Created by any on 8/25/25.
//

import Foundation
import UIKit

extension Data {
  var uiColor: UIColor? {
    try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: self)
  }
}
