//
//  DetailPhotoTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class DetailPhotoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleProductLabel: UILabel!
    @IBOutlet weak var infoPurchaseProduct: UILabel!
    
    var product: HistoryTransactionDetailItem? {
        didSet {
            guard let product = product as? ProductDetailModel else { return }
            titleLabel.text = "Produk"
            titleProductLabel.text = product.name
            productImageView.loadImage(at: product.photoUrl)
            infoPurchaseProduct.text = "\(product.quantity) x \(product.productPrice.toMoney())"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
