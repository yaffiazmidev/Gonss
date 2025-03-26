//
//  DonationFilterEmptyCollectionViewCell.swift
//  FeedCleeps
//
//  Created by DENAZMI on 03/04/23.
//

import UIKit

class DonationFilterEmptyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterContainerView: UIView!
    @IBOutlet weak var emptyFilterDonationContainerStackView: UIStackView!
    @IBOutlet weak var emptyDonationContainerStackView: UIStackView!
    
    var handleTapFilterButton: (() -> Void)?
    var handleReloadData: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didClickReloadButton(_ sender: Any) {
        handleReloadData?()
    }
    @IBAction func didClickFilterButton(_ sender: Any) {
        handleTapFilterButton?()
    }
}
