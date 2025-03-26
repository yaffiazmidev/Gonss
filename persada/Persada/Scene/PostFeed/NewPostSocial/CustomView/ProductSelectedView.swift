//
//  ChannelSelectedView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 12/08/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ProductSelectedView: UITableViewCell {

    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    var onCloseClicked = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        layer.cornerRadius = 8
        isUserInteractionEnabled = true
        productNameLabel.font = .Roboto(.medium, size: 12)
        productPriceLabel.font = .Roboto(.medium, size: 14)
        productImage.layer.cornerRadius = 6
        productImage.contentMode = .scaleAspectFill
    }
    
    func setupData(product: Product) {
        if let url = product.medias?.first?.thumbnail?.small {
            productImage.loadImage(at: url)
        }
        productNameLabel.text = product.name
        productPriceLabel.text = product.price?.toMoney()
    }
    
    @IBAction func onCloseClick(_ sender: UIButton) {
        onCloseClicked()
    }
    
}
