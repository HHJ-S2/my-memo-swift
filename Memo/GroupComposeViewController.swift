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
      DataManager.shared.update(group: group, name: text, backgroundColor: backgroundColorWell.selectedColor)
    } else {
      DataManager.shared.insert(group: text, backgroundColor: backgroundColorWell.selectedColor)
    }
    
    dismiss(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let group {
      nameField.text = group.title
      backgroundColorWell.selectedColor = group.backgroundColor
      navigationItem.title = "그룹 편집"
    } else {
      navigationItem.title = "새 그룹"
    }
    
    nameField.becomeFirstResponder()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if nameField.isFirstResponder {
      nameField.resignFirstResponder()
    }
  }
}
