//
//  TiktokEmptyTableViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 30/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class TiktokEmptyTableViewCell: UITableViewCell {
    @IBOutlet weak var refreshButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
}
