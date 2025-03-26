//
//  TotalHistoryTransactionTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class TotalHistoryTransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var type: TypeHistoryTransaction = .transaction
    
    var amount: HistoryTransactionDetailItem? {
        didSet {
            guard let amount = amount as? AmountDetailModel else { return }
            switch type {
            case .transaction, .commission, .reseller:
                totalLabel.text = "Total"
            default:
                totalLabel.text = "Total Dikembalikan"
            }
            priceLabel.text = amount.amount.toMoney()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
