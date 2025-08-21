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
  
  static let memoDidUpdate = Notification.Name("memoDidUpdate")
}

class ComposeViewController: UIViewController {
  
  // 메모 편집으로 접근하는 경우
  var editTarget: MemoEntity?
  
  // 편집 화면일때 이전 텍스트
  var originalContent = ""
  
  @IBOutlet weak var contnetTextView: UITextView!
  
  @IBAction func closeVC(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @IBAction func save(_ sender: Any) {
    guard let text = contnetTextView.text, text.count > 0 else {
      // TODO: 경고창 추가
      return
    }
    
    if let editTarget {
      DataManager.shared.update(entity: editTarget, content: text)
      NotificationCenter.default.post(name: .memoDidUpdate, object: nil, userInfo: ["memo": editTarget])
    } else {
      DataManager.shared.insert(memo: text)
      NotificationCenter.default.post(name: .memoDidInsert, object: nil)
    }
    
    dismiss(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    contnetTextView.becomeFirstResponder()
    
    if let editTarget {
      navigationItem.title = "편집"
      contnetTextView.text = editTarget.content
      originalContent = editTarget.content ?? ""
    } else {
      navigationItem.title = "새 메모"
      contnetTextView.text = ""
    }
    
    contnetTextView.delegate = self
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if contnetTextView.isFirstResponder {
      contnetTextView.resignFirstResponder()
    }
  }
  
  deinit {
    print(self, #function)
  }
}

extension ComposeViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    if let _ = editTarget {
      // 이전글이 지금글과 다를때 스와이프 닫기 불가
      isModalInPresentation = originalContent != textView.text
    } else {
      isModalInPresentation = !textView.text.isEmpty
    }
  }
}
