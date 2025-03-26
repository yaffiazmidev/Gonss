//
//  DonationWithdrawActivityTableViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 27/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class DonationWithdrawActivityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var createAtLabel: UILabel!
    @IBOutlet weak var withdrawAmountLabel: UILabel!
    @IBOutlet weak var withdrawByNameLabel: UILabel!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var horizontalLineView: UIView!
    @IBOutlet weak var badgesView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
