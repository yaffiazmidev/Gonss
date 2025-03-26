//
//  CoinPurchaseCollectionViewCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 10/08/23.
//

import UIKit
import KipasKipasDirectMessage

class CoinPurchaseCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceDiscountLabel: UILabel!
    @IBOutlet weak var priceFinalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with data: RemoteCoinPurchaseProductData) {
        nameLabel.text = data.description
        priceDiscountLabel.isHidden = true //Temporarry
        priceFinalLabel.text = format(double: data.price ?? 0)
    }
    
    private func format(double: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.init(identifier: "ID-id")
        formatter.numberStyle = .currency
        if let formatted = formatter.string(from: double as NSNumber) {
            return "\(formatted)"
        }
        return nil
    }
}
