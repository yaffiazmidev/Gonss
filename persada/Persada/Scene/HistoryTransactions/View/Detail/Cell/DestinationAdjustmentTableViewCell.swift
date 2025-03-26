//
//  DestinationAdjustmentTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 16/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class DestinationAdjustmentTableViewCell: UITableViewCell {
    @IBOutlet weak var destinationLabel: UILabel!
    
    var destination: HistoryTransactionDetailItem? {
        didSet {
            guard let destination = destination as? DestinationAdjustmentModel else { return }
            destinationLabel.text = "\(destination.destination)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
