//
//  CoinPurchaseHistoryTableViewCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 10/08/23.
//

import UIKit
import KipasKipasDirectMessage

class CoinPurchaseHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var coinPurchaseDetailContainerStackView: UIStackView!
    @IBOutlet weak var coinStatusLabel: UILabel!
    @IBOutlet weak var totalCoinLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(item: RemoteCurrencyHistoryContent) {
        
        switch item.activityType {
        case "GIFT":
            coinStatusLabel.text = "Live Gift"
            coinStatusLabel.textColor = .scarlet
            coinStatusLabel.font = .roboto(.medium, size: 14)
            
            totalCoinLabel.text = "-\(item.nominal ?? 0)"
            totalCoinLabel.textColor = .scarlet
            totalCoinLabel.font = .roboto(.medium, size: 14)
            
        case "DM_TRANSACTION":
            coinStatusLabel.text = "DM Berbayar"
            coinStatusLabel.textColor = .scarlet
            coinStatusLabel.font = .roboto(.medium, size: 14)
            
            totalCoinLabel.text = "-\(item.nominal ?? 0)"
            totalCoinLabel.textColor = .scarlet
            totalCoinLabel.font = .roboto(.medium, size: 14)
            
        case "TOP_UP":
            coinStatusLabel.text = "Beli Koin"
            coinStatusLabel.textColor = .gravel
            coinStatusLabel.font = .roboto(.medium, size: 14)
            
            totalCoinLabel.text = "+\(item.nominal ?? 0)"
            totalCoinLabel.textColor = .gravel
            totalCoinLabel.font = .roboto(.medium, size: 14)
            
        default:
            break
        }
        
        dateLabel.text = item.createAt?.toDate()
    }
}
