//
//  OrderNumberAdjustmentTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 16/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class OrderNumberAdjustmentTableViewCell: UITableViewCell {
    @IBOutlet weak var orderNumber: UILabel!
    
    var orderNo: HistoryTransactionDetailItem? {
        didSet {
            guard let orderNo = orderNo as? OrderNumberModel else { return }
            orderNumber.text = orderNo.orderNumber
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
