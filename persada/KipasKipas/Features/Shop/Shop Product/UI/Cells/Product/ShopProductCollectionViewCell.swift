//
//  ShopProductCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 28/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ShopProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
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
    @IBOutlet weak var discountPriceContainerStackView: UIStackView!
    @IBOutlet weak var disCountLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    private func setupShadowContainerView() {
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.masksToBounds = false
    }
    
    func setupViewForFilter(_ item: FilterProductViewModel) {
        //setup shadow & blur
        setupShadowContainerView()
        
        productImageView.loadImage(at: item.imageURL)
        productImageView.layer.cornerRadius = 8
        productImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        productPriceLabel.text = item.price.toMoney()
        productNameLabel.text = item.name
        totalSalesLabel.isHidden = item.totalSales == 0
        totalSalesLabel.text = "\(item.totalSales ?? 0)"
        locationLabel.text = item.city.capitalized
        
        setupRatingSalesViewForFilter(item)
        setupLocationView(item.city)
    }
    
    private func setupRatingSalesViewForFilter(_ item: FilterProductViewModel){
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
    
    func setupViewForShop(_ item: ShopViewModel) {
        //setup shadow & blur
        setupShadowContainerView()
        discountPriceLabel.strikethrough()
        productImageView.loadImage(at: item.imageURL)
        productImageView.layer.cornerRadius = 8
        productImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        productPriceLabel.text = item.price.toMoney()
        productNameLabel.text = item.name
//        totalSalesLabel.isHidden = item.totalSales == 0
        totalSalesLabel.text = "\(item.totalSales ?? 0)"
        locationLabel.text = item.city.capitalized
        
        setupRatingSalesViewForShop(item)
        setupLocationView(item.city)
    }
    
    private func setupRatingSalesViewForShop(_ item: ShopViewModel){
        let totalSales = item.totalSales ?? 0
        let rating = item.ratingAverage ?? 0
        print("***&& \(item.name) \(totalSales) \(rating)")
        
//        hideRatingSalesWhenEmpty(totalSales, rating) {
//            setupTotalSalesView(totalSales)
//            setupRatingView(rating)
//            
//            let totalSalesNotEmpty = !totalSalesStackView.isHidden
//            let ratingOrSalesEmpty = ratingStackView.isHidden || totalSalesStackView.isHidden
//            
//            ratingSpacerView.isHidden = totalSalesNotEmpty
//            verticalDividerView.isHidden = ratingOrSalesEmpty
//        }
        
        ratingSalesStackView.isHidden = false
        ratingStackView.isHidden = false
        ratingLabel.text = "\(rating)"
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
