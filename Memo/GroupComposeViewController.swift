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
    dismiss(animated: true)
  }
  
  @IBAction func save(_ sender: Any) {
    guard
      let text = nameField.text,
      (2...10).contains(text.count)
    else { return }
    
    if let group {
      do {
        // 그룹 수정
        try DataManager.shared.update(group: group, name: text, backgroundColor: backgroundColorWell.selectedColor)
      } catch {
        showAlert(error: error)
        return
      }
    } else {
      do {
        try DataManager.shared.insert(group: text, backgroundColor: backgroundColorWell.selectedColor)
      } catch {
        showAlert(error: error)
        return
      }
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
