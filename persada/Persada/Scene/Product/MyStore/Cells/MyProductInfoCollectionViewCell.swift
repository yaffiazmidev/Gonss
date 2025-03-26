//
//  MyProductInfoCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 12/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class MyProductInfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(title: String, actionBntTitle: String) {
        messageLabel.text = title
        messageButton.setTitle(actionBntTitle, for: .normal)
    }

}
