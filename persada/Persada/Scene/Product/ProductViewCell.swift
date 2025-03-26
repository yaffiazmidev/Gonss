//
//  ProductViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit

class ProductViewCell: UICollectionViewCell{
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var optionMore: UIImageView!
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
    @IBOutlet weak var updateStockButton: UIButton!
    @IBOutlet weak var emptyStockButton: UIButton!
    @IBOutlet weak var resellerEmblemView: UIStackView!
    @IBOutlet weak var resellerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupView(_ item: ProductItem, isSelf: Bool) {
        //setup shadow & blur
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.masksToBounds = false
        
        productImageView.loadImage(at: item.medias?.first?.thumbnail?.large ?? "", low: item.medias?.first?.thumbnail?.small ?? "", .w360, .w40)
        productImageView.layer.cornerRadius = 8
        productImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        productPriceLabel.text = (item.type == .original ? item.price : ((item.modal ?? 0) + (item.commission ?? 0))).toMoney()
        productNameLabel.text = item.name
        totalSalesLabel.isHidden = item.totalSales == 0
        totalSalesLabel.text = "Terjual \(item.totalSales)"
        locationLabel.text = item.city?.capitalized ?? ""
        resellerEmblemView.isHidden = true
        
        setupResellerView(item, isSelf: isSelf)
        setupRatingSalesView(item)
        setupLocationView(item.city)
        
        if isSelf {
            optionMore.isHidden = !(item.accountId.isItUser() || (item.type == .reseller && item.stock > 0))
            updateStockButton.isHidden = item.stock > 0
            emptyStockButton.isHidden = true
        } else {
            optionMore.isHidden = true
            updateStockButton.isHidden = true
            emptyStockButton.isHidden = item.stock > 0
        }
        
    }
    
    private func setupResellerView(_ item: ProductItem, isSelf: Bool){
        if item.isResellerAllowed {
            if isSelf {
                if item.type == .original {
                    showResellerProductEmblem()
                } else if item.type == .reseller {
                    showResellerCommissionEmblem(item.commission)
                }
            } else {
                if item.type == .original {
                    showResellerCommissionEmblem(item.commission)
                }
            }
        }
    }
    
    private func showResellerProductEmblem(){
        resellerEmblemView.backgroundColor = .grey
        resellerLabel.text = "Produk Reseller"
        resellerEmblemView.isHidden = false
    }
    
    private func showResellerCommissionEmblem(_ commission: Double?){
        resellerEmblemView.backgroundColor = .primary
        resellerLabel.text = "Komisi : \((commission ?? 0).toMoney())"
        resellerEmblemView.isHidden = false
    }
    
    private func setupRatingSalesView(_ item: ProductItem){
        let totalSales = item.totalSales
        let rating = item.ratingAverage
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
