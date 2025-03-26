//
//  DetailProductAdjustmentTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 16/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class DetailProductAdjustmentTableViewCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    
    var product: HistoryTransactionDetailItem? {
        didSet {
            guard let product = product as? ProductAdjustmentModel else { return }
            productName.text = product.productName
            productPrice.text = product.productPrice.toMoney()
            productQuantity.text = "\(product.quantity)x"
            productImage.loadImage(at: product.photoUrl)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
