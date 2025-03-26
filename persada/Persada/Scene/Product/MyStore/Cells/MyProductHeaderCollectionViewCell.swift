//
//  MyProductHeaderCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 11/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class MyProductHeaderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var refaundBalanceContainerView: UIView!
    @IBOutlet weak var salesBalanceContainerView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var salesBalanceLabel: UILabel!
    @IBOutlet weak var refundBalanceLabel: UILabel!
    @IBOutlet weak var viewTransactionHistoryButton: UIButton!
    @IBOutlet weak var withdrawBalenceButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(balance: MyStoreBalance?) {
        balanceLabel.text       = balance?.totalBalance.toMoney() ?? "Rp 0"
        salesBalanceLabel.text  = balance?.transactionBalance.toMoney() ?? "Rp 0"
        refundBalanceLabel.text = balance?.refundBalance.toMoney() ?? "Rp 0"
        
        let isRefaundBalanceEmpty = balance?.refundBalance ?? 0 == 0
        refundBalanceLabel.textColor                 = isRefaundBalanceEmpty ? .placeholder : .black
        refaundBalanceContainerView.backgroundColor  = isRefaundBalanceEmpty ? .clear : .white
        refaundBalanceContainerView.setShadowOpacity = isRefaundBalanceEmpty ? 0 : 1
        
        let isSalesBalanceEmpty = balance?.transactionBalance ?? 0 == 0
        salesBalanceLabel.textColor                = isSalesBalanceEmpty ? .placeholder : .black
        salesBalanceContainerView.backgroundColor  = isSalesBalanceEmpty ? .clear : .white
        salesBalanceContainerView.setShadowOpacity = isSalesBalanceEmpty ? 0 : 1
    }
}
