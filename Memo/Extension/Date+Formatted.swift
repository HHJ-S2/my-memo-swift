//
//  Date+Formatted.swift
//  Memo
//
//  Created by any on 8/25/25.
//

import Foundation

fileprivate let formatter: DateFormatter = {
  let formatter = DateFormatter()
  
  formatter.dateStyle = .medium
  formatter.timeStyle = .none
  
  return formatter
}()

extension Date {
  var relativeDateString: String? {
    let comps = Calendar.current.dateComponents([.second], from: self, to: .now)
    
    guard let seconds = comps.second else {
      return formatter.string(from: self)
    }
    
    if seconds < 60 {
      return "조금 전"
    } else if seconds < 3600 {
      let min = Int(seconds / 60)
      return "\(min)분 전"
    } else if seconds < 3600 * 24 {
      let hour = Int(seconds / 3600)
      return "\(hour)시간 전"
    } else {
      return formatter.string(from: self)
    }
  }
}
