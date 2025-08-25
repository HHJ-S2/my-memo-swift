//
//  UIController+Alert.swift
//  Memo
//
//  Created by any on 8/25/25.
//

import UIKit

extension UIViewController {
  func showAlert(message: String, title: String = "알림") {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "확인", style: .default)
    alert.addAction(okAction)
    
    present(alert, animated: true)
  }
  
  func showAlert(error: Error) {
    if let error = error as? String {
      showAlert(message: error)
    } else {
      showAlert(message: error.localizedDescription)
    }
  }
}
