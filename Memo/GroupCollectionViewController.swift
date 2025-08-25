//
//  GroupCollectionViewController.swift
//  Memo
//
//  Created by any on 8/22/25.
//

import UIKit
import CoreData

class GroupCollectionViewController: UICollectionViewController {
  
  var updates = [() -> ()]()
  
  func setupCollectionViewLayout() {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(200))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .flexible(10)
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    section.interGroupSpacing = 10
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    collectionView.collectionViewLayout = layout
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCollectionViewLayout()
    
    DataManager.shared.groupFetchedResults.delegate = self

    NotificationCenter.default.addObserver(forName: .ungroupedInfoDidUpdate, object: nil, queue: .main) { [weak self] _ in
      
      // numberOfObjects: 섹션안에 있는 셀의 개수
      if let index = DataManager.shared.groupFetchedResults.sections?.first?.numberOfObjects {
        // 마지막 indexPath
        let indexPath = IndexPath(item: index, section: 0)
        
        self?.collectionView.reloadItems(at: [indexPath])
      }
    }
  }
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
      
      // 추가한 그룹이 있는경우
      if let sections = DataManager.shared.groupFetchedResults.sections, sections[indexPath.section].numberOfObjects > indexPath.item {
        
        // 메모목록의 group 변수에 할당
        if let vc = segue.destination as? ListViewController {
          vc.group = DataManager.shared.groupFetchedResults.object(at: indexPath)
        }
      }
    }
  }
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return DataManager.shared.groupFetchedResults.sections?.count ?? 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let sections = DataManager.shared.groupFetchedResults.sections else { return 0 }
    
    return sections[section].numberOfObjects + 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GroupCollectionViewCell.self), for: indexPath) as! GroupCollectionViewCell
    
    // 그룹이 없는 마지막 셀
    if let sections = DataManager.shared.groupFetchedResults.sections, sections[indexPath.section].numberOfObjects == indexPath.item {
      cell.nameLabel.text = "그룹 없음"
      cell.contentView.backgroundColor = .yellow
      cell.lastUpdateDateLabel.text = DataManager.shared.ungroupedLastUpdate?.relativeDateString
      cell.memoCountLabel.text = "\(DataManager.shared.ungroupedMemoCount)"
    } else {
      let target = DataManager.shared.groupFetchedResults.object(at: indexPath)
      
      cell.nameLabel.text = target.title
      cell.contentView.backgroundColor = target.backgroundColor ?? .tertiarySystemFill
      cell.lastUpdateDateLabel.text = target.lastUpdated?.relativeDateString
      cell.memoCountLabel.text = "\(target.memoCount)"
    }
    
    return cell
  }
  
}

extension GroupCollectionViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
    updates.removeAll()
  }
  
  func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      if let insertIndexPath = newIndexPath {
        updates.append { [weak self] in
          self?.collectionView.insertItems(at: [insertIndexPath])
        }
      }
      
    case .delete:
      if let deleteIndexPath = newIndexPath {
        updates.append { [weak self] in
          self?.collectionView.deleteItems(at: [deleteIndexPath])
        }
      }
      
    case .move:
      if let originalIndexPath = indexPath, let targetIndexPath = newIndexPath {
        updates.append { [weak self] in
          self?.collectionView.moveItem(at: originalIndexPath, to: targetIndexPath)
        }
      }
      
    case .update:
      if let updateIndexPath = indexPath {
        updates.append { [weak self] in
          self?.collectionView.reloadItems(at: [updateIndexPath])
        }
      }
      
    default:
      break
    }
  }
  
  // Core Data에서 데이터 변경이 완료된 시점에 호출
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    // 여러 개의 삽입/삭제/이동 애니메이션을 한 번에 묶어서 실행
    collectionView.performBatchUpdates { [weak self] in
      self?.updates.forEach({ $0() }) // () -> void 타입의 updates를 모두 실행
    } completion: { [weak self] _ in
      self?.updates.removeAll()
    }
  }
}
