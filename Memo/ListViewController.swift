//
//  ViewController.swift
//  Memo
//
//  Created by any on 8/20/25.
//

import UIKit

class ListViewController: UIViewController {

  @IBOutlet weak var memoTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    DataManager.shared.fetch()
    
    // 메모 추가시 tableView reload
    NotificationCenter.default.addObserver(forName: .memoDidInsert, object: nil, queue: .main) { _ in
      // self.memoTableView.reloadData() // 전체 셀 삭제후 다시 그림
      
      let IndexPath = IndexPath(row: 0, section: 0)
      
      // 다른 셀은 그대로 두고 상단에 새로운 메모 셀만 추가
      self.memoTableView.insertRows(at: [IndexPath], with: .automatic)
    }
    
    NotificationCenter.default.addObserver(forName: .memoDidUpdate, object: nil, queue: .main) { noti in
      if let memo = noti.userInfo?["memo"] as? MemoEntity, let index = DataManager.shared.list.firstIndex(of: memo) {
        let indexPath = IndexPath(row: index, section: 0)
        
        self.memoTableView.reloadRows(at: [indexPath], with: .automatic)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let cell = sender as? UITableViewCell, let indexPath = memoTableView.indexPath(for: cell) {
      if let vc = segue.destination as? DetailViewController {
        vc.memo = DataManager.shared.list[indexPath.row]
      }
    }
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

extension ListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
