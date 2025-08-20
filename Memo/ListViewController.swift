//
//  ViewController.swift
//  Memo
//
//  Created by any on 8/20/25.
//

import UIKit

class ListViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    DataManager.shared.fetch()
  }
}

extension ListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DataManager.shared.list.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let target = DataManager.shared.list[indexPath.row]
    
    cell.textLabel?.text = target.content
    cell.detailTextLabel?.text = target.dateString
    
    return cell
  }
}
