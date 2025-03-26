//
//  CleepsLoadErrorCell.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 10/10/22.
//

import UIKit

class CleepsLoadErrorCell: UICollectionViewCell {

    var onRefresh: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    @IBAction func refreshClicked(_ sender: UIButton) {
        onRefresh?()
    }
}
