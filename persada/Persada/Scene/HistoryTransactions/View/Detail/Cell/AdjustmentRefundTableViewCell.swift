//
//  AdjustmentRefundTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 16/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class AdjustmentRefundTableViewCell: UITableViewCell {
    @IBOutlet weak var ongkirAwal: UILabel!
    @IBOutlet weak var kurangBayar: UILabel!
    @IBOutlet weak var totalOngkir: UILabel!
    
    var model: HistoryTransactionDetailItem? {
        didSet {
            guard let model = model as? AdjustmentRefundModel else { return }
            ongkirAwal.text = model.ongkirAwal.toMoney()
            kurangBayar.text = "+ \(model.kurangBayar.toMoney())"
            totalOngkir.text = model.totalOngkir.toMoney()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
