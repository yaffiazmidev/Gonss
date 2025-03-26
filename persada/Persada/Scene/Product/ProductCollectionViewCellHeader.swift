//
//  MyProductCollectionCellViewHeader.swift
//  KipasKipas
//
//  Created by DENAZMI on 14/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ProductCollectionViewCellHeader: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: "PRODUCT LIST", font: .Roboto(.medium, size: 12), textColor: .black)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(titleLabel)
        
        titleLabel.frame = CGRect(x: 16, y: 16, width: frame.width, height: 16)
    }
}
