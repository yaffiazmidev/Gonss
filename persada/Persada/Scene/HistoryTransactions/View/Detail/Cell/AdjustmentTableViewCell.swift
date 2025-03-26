//
//  AdjustmentTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 24/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class AdjustmentTableViewCell: UITableViewCell {
    @IBOutlet weak var shipmentInitalLabel: UILabel!
    @IBOutlet weak var shipmentReturnLabel: UILabel!
    @IBOutlet weak var shipmentFinaleLabel: UILabel!
    
    var adjustmentModel: HistoryTransactionDetailItem? {
        didSet {
            guard let adjustment = adjustmentModel as? AdjustmentModel else { return }
            shipmentInitalLabel.text = "\(adjustment.shipmentCostInitial)"
            shipmentReturnLabel.text = "\(adjustment.shipmentCostReturn)"
            shipmentFinaleLabel.text = "\(adjustment.shipmentCostFinal)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
