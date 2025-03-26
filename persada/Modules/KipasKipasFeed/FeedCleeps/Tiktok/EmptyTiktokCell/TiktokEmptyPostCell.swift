//
//  TiktokEmptyTableViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 30/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class TiktokEmptyPostCell: UICollectionViewCell {
    
    var onRefresh: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    @IBAction func refreshClicked(_ sender: UIButton) {
        onRefresh?()
    }
}
