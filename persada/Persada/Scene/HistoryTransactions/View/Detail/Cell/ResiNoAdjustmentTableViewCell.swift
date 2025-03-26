//
//  ResiNoAdjustmentTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 16/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ResiNoAdjustmentTableViewCell: UITableViewCell {
    @IBOutlet weak var noResiLabel: UILabel!
    
    var noResi: HistoryTransactionDetailItem? {
        didSet {
            guard let resi = noResi as? NoResiModel else { return }
            noResiLabel.text = "\(resi.noResi)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
