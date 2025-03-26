//
//  TiktokContentEmptyCollectionViewCell.swift
//  FeedCleeps
//
//  Created by DENAZMI on 26/12/22.
//

import UIKit

class TiktokContentEmptyCollectionViewCell: UICollectionViewCell {
    var onRefresh: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    @IBAction func refreshClicked(_ sender: UIButton) {
        onRefresh?()
    }

}
