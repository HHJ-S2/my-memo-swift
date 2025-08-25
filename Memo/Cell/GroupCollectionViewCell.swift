//
//  GroupCollectionViewCell.swift
//  Memo
//
//  Created by any on 8/22/25.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell {
    
  @IBOutlet weak var nameLabel: UILabel!
  
  @IBOutlet weak var lastUpdateDateLabel: UILabel!
  
  @IBOutlet weak var memoCountLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentView.layer.cornerRadius = 20
    contentView.clipsToBounds = true
  }
}
