//
//  ShopSpecialDiscountItemCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 01/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShopSpecialDiscountItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productPriceAfterDiscountLabel: UILabel!
    @IBOutlet weak var productDiscountLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productPriceAfterDiscountLabel.strikethrough()
    }

    func setupView(item: RemoteProductEtalaseData) {
        productPriceLabel.text = item.price?.toMoney()
        productPriceAfterDiscountLabel.text = item.priceAfterDiscount?.toMoney()
        productDiscountLabel.text = "\(item.discount ?? 0)%"
        productImageView.loadImageWithoutOSS(at: item.medias?.first?.thumbnail?.medium ?? "")
    }
}
