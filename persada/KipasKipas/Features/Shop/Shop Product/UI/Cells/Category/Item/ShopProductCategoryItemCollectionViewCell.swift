//
//  ShopProductCategoryItemCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 03/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShopProductCategoryItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var indicatorViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var isSelectedCategory: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorViewWidthConstraint.constant = isSelectedCategory ? 20 : 0
        layoutIfNeeded()
    }
}
