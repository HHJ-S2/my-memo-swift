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
  }
}
