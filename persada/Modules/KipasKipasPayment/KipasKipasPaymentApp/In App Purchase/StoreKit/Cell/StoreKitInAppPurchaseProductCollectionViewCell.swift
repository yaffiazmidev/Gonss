//
//  StoreKitInAppPurchaseProductCollectionViewCell.swift
//  KipasKipasPaymentApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/09/23.
//

import UIKit
import KipasKipasPaymentInAppPurchase

class StoreKitInAppPurchaseProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with data: InAppPurchaseProduct){
        self.nameLabel.text = data.localizedTitle
        
        let formatter = NumberFormatter()
        formatter.locale = data.priceLocale
        formatter.numberStyle = .currency
        self.priceLabel.text = formatter.string(from: data.price as NSNumber)
    }
}
