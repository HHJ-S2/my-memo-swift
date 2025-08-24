//
//  ViewController.swift
//  Memo
//
//  Created by any on 8/20/25.
//

import UIKit
import CoreData

class ListViewController: UIViewController {

  @IBOutlet weak var memoTableView: UITableView!
  
  // VC가 뷰 계층에 추가 되었을때 reload 하기위함
  // var reloadTargetIndexPath: IndexPath?
  
  // var deleteTargetIndexPath: IndexPath?
  
  var group: GroupEntity?
  
  // 네비게이션 검색 바
  func setupSearchBar() {
    let searchController = UISearchController(searchResultsController: nil)
   
    searchController.searchBar.placeholder = "메모 내용으로 검색"
    searchController.searchResultsUpdater = self // 업데이트 담당 VC 지정
    
    navigationItem.searchController = searchController
  }
  
  @objc func resetCache() {
    NSFetchedResultsController<MemoEntity>.deleteCache(withName: nil)
    DataManager.shared.fetch(group: group)
    memoTableView.refreshControl?.endRefreshing()
  }
  
  func setupPullToRefresh() {
    let refreshControl = UIRefreshControl()
    
    refreshControl.addTarget(self, action: #selector(resetCache), for: .valueChanged)
    memoTableView.refreshControl = refreshControl
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // DataManager.shared.fetch()
    setupSearchBar()
    setupPullToRefresh()
    
    DataManager.shared.memoFetchedResults.delegate = self
    DataManager.shared.fetch(group: group)
    
    navigationItem.title = group?.title ?? "그룹없음"
    
    /**
    // 메모 추가시 tableView reload
    NotificationCenter.default.addObserver(forName: .memoDidInsert, object: nil, queue: .main) { [weak self] _ in
      // self.memoTableView.reloadData() // 전체 셀 삭제후 다시 그림
      
      guard let self = self else { return }
      
      let IndexPath = IndexPath(row: 0, section: 0)
      
      // 다른 셀은 그대로 두고 상단에 새로운 메모 셀만 추가
      self.memoTableView.insertRows(at: [IndexPath], with: .automatic)
    }
    
    NotificationCenter.default.addObserver(forName: .memoDidUpdate, object: nil, queue: .main) { [weak self] noti in
      guard let self = self else { return }
      
      if let memo = noti.userInfo?["memo"] as? MemoEntity, let index = DataManager.shared.list.firstIndex(of: memo) {
        let indexPath = IndexPath(row: index, section: 0)
        
        // VC가 뷰 계층에 추가되어있지 않을때 reload 하는경우 warning
        // self.memoTableView.reloadRows(at: [indexPath], with: .automatic)
        
        self.reloadTargetIndexPath = indexPath
      }
    }
    
    NotificationCenter.default.addObserver(forName: .memoDidDelete, object: nil, queue: .main) { [weak self] noti in
      guard let self = self else { return }
      
      if let index = noti.userInfo?["index"] as? Int {
        let indexPath = IndexPath(row: index, section: 0)
        
        self.deleteTargetIndexPath = indexPath
      }
    }
     */
  }
  
  override func viewIsAppearing(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    /**
    if let reloadTargetIndexPath {
      self.memoTableView.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
      self.reloadTargetIndexPath = nil
    }
    
    if let deleteTargetIndexPath {
      self.memoTableView.deleteRows(at: [deleteTargetIndexPath], with: .automatic)
      self.deleteTargetIndexPath = nil
    }
     */
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let cell = sender as? UITableViewCell, let indexPath = memoTableView.indexPath(for: cell) {
      if let vc = segue.destination as? DetailViewController {
        // vc.memo = DataManager.shared.list[indexPath.row]
        vc.memo = DataManager.shared.memoFetchedResults.object(at: indexPath)
      }
    } else if let vc = segue.destination.children.first as? ComposeViewController {
      vc.group = group
    }
  }
}

extension ListViewController: UITableViewDataSource {
  // 섹션 개수
  func numberOfSections(in tableView: UITableView) -> Int {
    return DataManager.shared.memoFetchedResults.sections?.count ?? 0
  }
  
  // 섹션 내 row 개수
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // return DataManager.shared.list.count
    
    guard let sections = DataManager.shared.memoFetchedResults.sections else { return 0 }
    
    let sectionInfo = sections[section]
    
    print("sectionInfo: \(sectionInfo.numberOfObjects)")
    
    return sectionInfo.numberOfObjects
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    // let target = DataManager.shared.list[indexPath.row]
    let target = DataManager.shared.memoFetchedResults.object(at: indexPath)
    
    cell.textLabel?.text = target.content
    cell.detailTextLabel?.text = target.dateString
    
    return cell
  }
  
  // 우측 스와이프 액션
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      DataManager.shared.delete(at: indexPath)
      // tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
}

extension ListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ListViewController: UISearchResultsUpdating {
  // 서치바로 검색시 호출
  func updateSearchResults(for searchController: UISearchController) {
    // 호출이 끝나기 전 항상 실행
    defer {
      memoTableView.reloadData()
    }
    
    guard let keyword = searchController.searchBar.text, keyword.count > 0 else {
      DataManager.shared.fetch(group: group)
      return
    }
    
    DataManager.shared.fetch(group: group, keyword: keyword)
  }
}


extension ListViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
    memoTableView.beginUpdates()
  }
  
  // 개별 entity가 업데이트 될 때마다 호출됨
  func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      if let insertIndexPath = newIndexPath {
        memoTableView.insertRows(at: [insertIndexPath], with: .automatic)
      }
    case .delete:
      if let deleteIndexPath = indexPath {
        memoTableView.deleteRows(at: [deleteIndexPath], with: .automatic)
      }
    case .update:
      if let updateIndexPath = indexPath {
        memoTableView.reloadRows(at: [updateIndexPath], with: .automatic)
      }
    case .move:
      if let originalIndexPath = indexPath, let targetIndexPath = newIndexPath {
        memoTableView.moveRow(at: originalIndexPath, to: targetIndexPath)
      }
    default:
      break
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
    memoTableView.endUpdates()
  }
}
