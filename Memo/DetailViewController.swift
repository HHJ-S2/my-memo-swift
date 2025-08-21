//
//  DetailViewController.swift
//  Memo
//
//  Created by any on 8/20/25.
//

import UIKit

// extension Notification.Name {
//   static let memoDidDelete = Notification.Name("memoDidDelete")
// }

class DetailViewController: UIViewController {
  
  @IBOutlet weak var contentTextView: UITextView!

  var memo: MemoEntity?
  
  @IBAction func deleteMemo(_ sender: Any) {
    let alert = UIAlertController(title: "삭제 확인", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
      guard let memo = self?.memo else { return }
      
      // if let index = DataManager.shared.delete(entity: memo) {
      //   print(index)
      //   NotificationCenter.default.post(name: .memoDidDelete, object: nil, userInfo: ["index": index])
      // }
      
      DataManager.shared.delete(entity: memo)
      
      self?.navigationController?.popViewController(animated: true)
    }
    alert.addAction(okAction)
    
    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
    alert.addAction(cancelAction)
    
    present(alert, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let memo {
      contentTextView.text = memo.content
    }
    
    // 메모 업데이트 옵저버
    // NotificationCenter.default.addObserver(forName: .memoDidUpdate, object: nil, queue: .main) { [weak self] _ in
    //   guard let self else { return } // 옵저버에서 self 사용시 강한참조 주의
    //   
    //   self.contentTextView.text = self.memo?.content
    // }
    
    NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: .main) { [weak self] _ in
      guard let self else { return }
    
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
