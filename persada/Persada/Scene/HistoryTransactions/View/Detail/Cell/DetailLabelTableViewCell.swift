//
//  DetailLabelTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class DetailLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    var type: TypeHistoryTransaction = .transaction
    
    var dateDetail: HistoryTransactionDetailItem? {
        didSet {
            guard let dateDetail = dateDetail as? DateDetailModel else { return }
            switch type {
            case .transaction, .commission, .reseller:
                titleLabel.text = "Tanggal Pembelian"
            default:
                titleLabel.text = "Tanggal Refund"
            }
            let date = Date(milliseconds: Int64(dateDetail.date)).toString(format: "dd/MM/yyyy HH:mm")
            captionLabel.text = "\(date)"
        }
    }
    
    var invoice: HistoryTransactionDetailItem? {
        didSet {
            guard let invoice = invoice as? InvoiceDetailModel else { return }
            titleLabel.text = "Invoice"
            captionLabel.text = invoice.noInvoice
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
