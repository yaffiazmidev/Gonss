//
//  HistoryTransactionTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 20/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class HistoryTransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var iconLinkImageView: UIImageView!
    
    var data: HistoryTransactionModel? {
        didSet {
            if let value = data {
                switch value.historyType {
                case "CREDIT":
                    let date = Date(milliseconds: Int64(value.date)).toString(format: "dd/MM/yyyy")
                    moneyLabel.textColor = UIColor(hexString: "FF4265")
                    dateLabel.text = "\(date)"
                    moneyLabel.text = "\(String(value.currency).toMoney())"
                    description(value: value)
                    iconLinkImageView.isHidden = true
                default:
                    let date = Date(milliseconds: Int64(value.date)).toString(format: "dd/MM/yyyy")
                    moneyLabel.textColor = UIColor(hexString: "1890FF")
                    dateLabel.text = "\(date)"
                    moneyLabel.text = String(value.currency).toMoney()
                    description(value: value)
                    iconLinkImageView.isHidden = false
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func description(value: HistoryTransactionModel) {
        switch (value.activityType, value.historyType) {
        case ("TRANSACTION", "DEBIT"):
            descLabel.text = "PENJUALAN"
        case ("COMMISSION", "DEBIT"):
            descLabel.text = "KOMISI"
        case ("TRANSACTION", "CREDIT"):
            descLabel.textColor = UIColor(hexString: "FF4265")
            descLabel.text = "PENARIKAN SALDO"
        case ("REFUND", "DEBIT"):
            descLabel.text = "REFUND"
        case ("MODAL", "DEBIT"):
            descLabel.text = "RESELLER"
        default:
            descLabel.text = ""
        }
    }
}
