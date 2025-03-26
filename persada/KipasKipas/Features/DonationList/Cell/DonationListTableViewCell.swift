//
//  DonationListTableViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class DonationListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var expiredAtLabel: UILabel!
    @IBOutlet weak var amountCollectedLabel: UILabel!
    @IBOutlet weak var donationImageView: UIImageView!
    @IBOutlet weak var withdrawBalanceButton: UIButton!
    @IBOutlet weak var amountCollectedProgressBar: UIProgressView!
    @IBOutlet weak var amountAvailableLabel: UILabel!
    @IBOutlet weak var amountWithdrawLabel: UILabel!
    @IBOutlet weak var amountCollectedAdminFeeLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupView(item: RemoteDonationContent) {
        let media = item.medias?.filter({ $0.type == "image" }).first
        donationImageView.loadImage(at: media?.thumbnail?.large ?? "")
        amountCollectedProgressBar.progress = item.amountCollectedPercent
        amountAvailableLabel.text = item.amountAvailable?.toMoney()
        amountWithdrawLabel.text = item.amountWithdraw?.toMoney()
        amountCollectedAdminFeeLabel.text = item.amountCollectedAdminFee?.toMoney() ?? "Rp 0"
        expiredAtLabel.isHidden = item.expiredAt ?? 0 == 0
        expiredAtLabel.text = "Berakhir pada \(item.expiredAt?.toDateString() ?? "-")"
        amountAvailableLabel.font = .Roboto(.bold, size: 10)
        amountCollectedAdminFeeLabel.font = .Roboto(.bold, size: 10)
        amountWithdrawLabel.font = .Roboto(.bold, size: 10)
        
        let amountCollected = item.amountCollected?.toMoney() ?? "Rp 0"
        let amountCollectedAttribute = amountCollected.attributedText(font: .Roboto(.bold, size: 17), textColor: .primary)

        if let targetAmount = item.targetAmount, targetAmount != 0.0 {
            let targetAmountAttribute = " / \(targetAmount.toMoney())".attributedText(font: .Roboto(.bold, size: 12), textColor: .contentGrey)
            amountCollectedAttribute.append(targetAmountAttribute)
        }
        
        amountCollectedLabel.attributedText = amountCollectedAttribute
    }
}
