//
//  MyProductCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 12/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class MyProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var optionMore: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupView(_ item: Product) {
        productImageView.loadImage(at: item.medias?.first?.thumbnail?.large ?? "", low: item.medias?.first?.thumbnail?.small ?? "", .w360, .w40)
        productPriceLabel.text = item.price?.toMoney() ?? "0".toMoney()
        productNameLabel.text = item.name
        
        if let id = item.accountId {
            if id.isItUser() {
                optionMore.isHidden = false
            } else {
                optionMore.isHidden = true
            }
        }
    }
}
