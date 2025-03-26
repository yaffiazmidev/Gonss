//
//  ShopProductRecomItemCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 28/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ShopProductRecomItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingSalesStackView: UIStackView!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingSpacerView: UIView!
    @IBOutlet weak var verticalDividerView: UIView!
    @IBOutlet weak var totalSalesStackView: UIStackView!
    @IBOutlet weak var totalSalesLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupView(_ item: RecommendShopViewModel) {
        //setup shadow & blur
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.masksToBounds = false
        
        productImageView.loadImage(at: item.imageURL)
        productImageView.layer.cornerRadius = 8
        productImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        productPriceLabel.text = item.price.toMoney()
        productNameLabel.text = item.name
        totalSalesLabel.isHidden = item.totalSales == 0
        totalSalesLabel.text = "Terjual \(item.totalSales ?? 0)"
        locationLabel.text = item.city.capitalized
        
        setupRatingSalesView(item)
        setupLocationView(item.city)
    }
    
    private func setupRatingSalesView(_ item: RecommendShopViewModel){
        let totalSales = item.totalSales ?? 0
        let rating = item.ratingAverage ?? 0
        print("***&& \(item.name) \(totalSales) \(rating)")
        
        hideRatingSalesWhenEmpty(totalSales, rating) {
            setupTotalSalesView(totalSales)
            setupRatingView(rating)
            
            let totalSalesNotEmpty = !totalSalesStackView.isHidden
            let ratingOrSalesEmpty = ratingStackView.isHidden || totalSalesStackView.isHidden
            
            ratingSpacerView.isHidden = totalSalesNotEmpty
            verticalDividerView.isHidden = ratingOrSalesEmpty
        }
    }
    
    private func hideRatingSalesWhenEmpty(_ totalSales: Int, _ rating: Double, whenNotEmpty: () -> Void ){
        let isEmpty = totalSales < 1 && rating == 0
        
        ratingSalesStackView.isHidden = isEmpty
        if isEmpty { return }
        whenNotEmpty()
    }
    
    private func setupTotalSalesView(_ totalSales: Int){
        let salesEmpty = totalSales < 1
        totalSalesStackView.isHidden = salesEmpty
        
        if !salesEmpty {
            totalSalesLabel.text = "\(totalSales)"
        }
    }
    
    private func setupRatingView(_ rating: Double){
        let ratingEmpty = rating == 0
        ratingStackView.isHidden = ratingEmpty
        
        if !ratingEmpty {
            ratingLabel.text = "\(rating)"
        }
    }
    
    private func setupLocationView(_ city: String?){
        let cityEmpty = city.isNilOrEmpty
        locationStackView.isHidden = cityEmpty
        
        if cityEmpty {
            locationLabel.text = city?.capitalized ?? ""
        }
    }
}
