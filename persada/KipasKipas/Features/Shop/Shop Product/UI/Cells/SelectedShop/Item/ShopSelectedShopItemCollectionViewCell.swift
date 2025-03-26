//
//  ShopSelectedShopItemCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 02/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShopSelectedShopItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeCityLabel: UILabel!
    @IBOutlet weak var storeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupView(item: RemoteStoreItemData) {
        thumbnailImageView.loadImage(at: item.thumbnail?.medium ?? "", .w480)
        storeImageView.loadImage(at: item.photo ?? "", .w360)
        storeNameLabel.text = item.sellerName ?? "-"
        storeCityLabel.text = item.city ?? "-"
    }
}
