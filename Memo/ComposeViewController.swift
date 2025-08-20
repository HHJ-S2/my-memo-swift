//
//  ComposeViewController.swift
//  Memo
//
//  Created by any on 8/20/25.
//

import UIKit

extension Notification.Name {
  // 메모 추가 리스너
  static let memoDidInsert = Notification.Name("memoDidInsert")
}

class ComposeViewController: UIViewController {
  @IBOutlet weak var contnetTextView: UITextView!
  
  @IBAction func closeVC(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @IBAction func save(_ sender: Any) {
    guard let text = contnetTextView.text, text.count > 0 else {
      // TODO: 경고창 추가
      return
    }
    
    DataManager.shared.insert(memo: text)
    NotificationCenter.default.post(name: .memoDidInsert, object: nil)
    
    dismiss(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    contnetTextView.becomeFirstResponder()
    navigationItem.title = "새 메모"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if contnetTextView.isFirstResponder {
      contnetTextView.resignFirstResponder()
    }
  }
}
