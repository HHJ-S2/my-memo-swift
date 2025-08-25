//
//  GroupComposeViewController.swift
//  Memo
//
//  Created by any on 8/25/25.
//

import UIKit

class GroupComposeViewController: UIViewController {
  
  var group: GroupEntity?
  
  @IBOutlet weak var backgroundColorWell: UIColorWell!
  
  @IBOutlet weak var nameField: UITextField!
  
  
  @IBAction func closeVC(_ sender: Any) {
  }
  
  @IBAction func save(_ sender: Any) {
    guard let text = nameField.text, text.count > 0 else { return }
    
    if let group {
      // 그룹 수정
    } else {
      DataManager.shared.insert(group: text, backgroundColor: backgroundColorWell.selectedColor)
    }
    
    dismiss(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let group {
      
    } else {
      navigationItem.title = "새 그룹"
    }
  }
  
}
