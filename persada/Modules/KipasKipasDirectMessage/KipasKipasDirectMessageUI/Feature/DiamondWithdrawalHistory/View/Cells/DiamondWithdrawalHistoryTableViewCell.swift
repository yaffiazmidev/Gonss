//
//  DiamondWithdrawalHistoryTableViewCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 11/08/23.
//

import UIKit
import KipasKipasDirectMessage

public enum DiamondActivityType: String {
    case dm = "DM_TRANSACTION"
    case withdrawal = "WITHDRAWAL"
    case gift = "GIFT"
}

public enum DiamondHistoryType: String {
    case debit = "DEBIT"
    case credit = "CREDIT"
    case transaction = "TRANSACTION"
}

public enum DiamondPurchaseStatus: String {
    case complete = "COMPLETE"
    case process = "PROCESS"
}

class DiamondWithdrawalHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var diamondDetailContainerStackView: UIStackView!
    @IBOutlet weak var totalDiamondLabel: UILabel!
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
        let historyType = DiamondHistoryType(rawValue: item.historyType ?? "")
        let activityType = DiamondActivityType(rawValue: item.activityType ?? "")
        
        switch historyType {
        case .credit:
            totalDiamondLabel.font = .roboto(.medium, size: 14)
            totalDiamondLabel.textColor = .ferrariRed
            
        case .debit:
            totalDiamondLabel.font = .roboto(.medium, size: 14)
            totalDiamondLabel.textColor = .gravel
            
        default: break
        }
        
        switch activityType {
        case .dm:
            totalDiamondLabel.text = "DM Berbayar +" + "\(item.nominal ?? 0)"
            
        case .gift:
            totalDiamondLabel.text = "Pendapatan Live +" + "\(item.nominal ?? 0)"
            
        case .withdrawal:
            totalDiamondLabel.text = "Penarikan -" + "\(item.nominal ?? 0)"
            
        default: break
        }
        
        dateLabel.text = item.createAt?.toDate()
    }
}
