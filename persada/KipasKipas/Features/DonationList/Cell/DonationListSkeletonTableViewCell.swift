//
//  DonationListSkeletonTableViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 20/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class DonationListSkeletonTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: ShimmerView!
    @IBOutlet weak var titleView: ShimmerView!
    @IBOutlet weak var amountCollectedView: ShimmerView!
    @IBOutlet weak var progressBarView: ShimmerView!
    @IBOutlet weak var expDateView: ShimmerView!
    @IBOutlet weak var amountAvailableView: ShimmerView!
    @IBOutlet weak var amountWithdrawView: ShimmerView!
    @IBOutlet weak var withdrawButtonView: ShimmerView!
    @IBOutlet weak var detailButtonView: ShimmerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coverImageView.startAnimating()
        titleView.startAnimating()
        amountCollectedView.startAnimating()
        progressBarView.startAnimating()
        expDateView.startAnimating()
        amountAvailableView.startAnimating()
        amountWithdrawView.startAnimating()
        withdrawButtonView.startAnimating()
        detailButtonView.startAnimating()
    }
}
