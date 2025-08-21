//
//  DetailViewController.swift
//  Memo
//
//  Created by any on 8/20/25.
//

import UIKit

class DetailViewController: UIViewController {
  
  @IBOutlet weak var contentTextView: UITextView!
  
  var memo: MemoEntity?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let memo {
      contentTextView.text = memo.content
    }
    
    // 메모 업데이트 옵저버
    NotificationCenter.default.addObserver(forName: .memoDidUpdate, object: nil, queue: .main) { [weak self] _ in
      guard let self else { return } // 옵저버에서 self 사용시 강한참조 주의
      
      self.contentTextView.text = self.memo?.content
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination.children.first as? ComposeViewController {
      vc.editTarget = memo
    }
  }
  
  deinit {
    print(self, #function)
  }
}
