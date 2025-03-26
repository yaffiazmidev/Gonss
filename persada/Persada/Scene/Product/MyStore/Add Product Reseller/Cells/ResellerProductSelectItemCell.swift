//
//  ResellerProductSelectItemCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 22/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit

class ResellerProductSelectItemCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.setCornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
        label.font = .Roboto(.medium, size: 14)
        return label
    }()
    
    lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .contentGrey
        label.font = .Roboto(.regular, size: 12)
        return label
    }()
    
    lazy var ratingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let star = UIImageView(image: UIImage(named: .get(.iconProductStarFill)))
        
        view.addSubViews([ratingLabel, star])
        ratingLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor)
        star.anchor(top: view.topAnchor, left: ratingLabel.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,  paddingLeft: 2, width: 14, height: 14)
        
        return view
    }()
    
    lazy var verticalDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gainsboro
        view.translatesAutoresizingMaskIntoConstraints = false
        view.anchor(width: 1, height: 12)
        return view
    }()
    
    lazy var salesTotalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .contentGrey
        label.font = .Roboto(.medium, size: 12)
        return label
    }()
    
    lazy var salesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.textColor = .contentGrey
        label.font = .Roboto(.regular, size: 12)
        label.text = "Terjual"
        
        view.addSubViews([label, salesTotalLabel])
        label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor)
        salesTotalLabel.anchor(top: view.topAnchor, left: label.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,  paddingLeft: 2)
        
        return view
    }()
    
    lazy var ratingSalesView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [ratingView, verticalDividerView, salesView])
        view.spacing = 5
        view.alignment = .center
        view.distribution = .fill
        view.axis = .horizontal
        return view
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primary
        label.font = .Roboto(.bold, size: 16)
        return label
    }()
    
    lazy var commissionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .Roboto(.bold, size: 10)
        return label
    }()
    
    lazy var commissionView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary
        view.setCornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.textColor = .white
        label.font = .Roboto(.bold, size: 10)
        label.text = "Komisi :"
        
        view.addSubViews([label, commissionLabel])
        label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 2, paddingLeft: 6, paddingBottom: 2)
        commissionLabel.anchor(top: view.topAnchor, left: label.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 2, paddingLeft: 4, paddingBottom: 2, paddingRight: 6)
        
        return view
    }()
    
    let divider = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let priceCommissionView = UIView()
        priceCommissionView.addSubViews([priceLabel, commissionView])
        priceLabel.anchor(top: priceCommissionView.topAnchor, left: priceCommissionView.leftAnchor, bottom: priceCommissionView.bottomAnchor)
        commissionView.anchor(left: priceLabel.rightAnchor, paddingLeft: 8)
        commissionView.centerYTo(priceCommissionView.centerYAnchor)
        
        let mainView = UIStackView(arrangedSubviews: [nameLabel, ratingSalesView, priceCommissionView, divider])
        mainView.spacing = 6
        mainView.alignment = .leading
        mainView.distribution = .fillEqually
        mainView.axis = .vertical
        
        addSubViews([imageView, mainView])
        
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, width: 64, height: 64)
        mainView.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(_ item: ProductItem) {
        imageView.loadImage(at: item.medias?.first?.thumbnail?.large ?? "", low: item.medias?.first?.thumbnail?.small ?? "", .w360, .w40)
        priceLabel.text = item.price.toMoney()
        commissionLabel.text = (item.commission ?? 0).toMoney() 
        nameLabel.text = item.name
        salesView.isHidden = item.totalSales == 0
        salesTotalLabel.text = "\(item.totalSales)"
        divider.isHidden = item.totalSales != 0
        setupRatingSalesView(item)
    }
    
    
    private func setupRatingSalesView(_ item: ProductItem){
        let totalSales = item.totalSales
        let rating = item.ratingAverage
        
        hideRatingSalesWhenEmpty(totalSales, rating) {
            setupTotalSalesView(totalSales)
            setupRatingView(rating)
            
            let totalSalesNotEmpty = !salesView.isHidden
            let ratingOrSalesEmpty = ratingView.isHidden || salesView.isHidden
            
//            ratingSpacerView.isHidden = totalSalesNotEmpty
            verticalDividerView.isHidden = ratingOrSalesEmpty
        }
    }
    
    private func hideRatingSalesWhenEmpty(_ totalSales: Int, _ rating: Double, whenNotEmpty: () -> Void ){
        let isEmpty = totalSales < 1 && rating == 0
        
        ratingSalesView.isHidden = isEmpty
        if isEmpty { return }
        whenNotEmpty()
    }
    
    private func setupTotalSalesView(_ totalSales: Int){
        let salesEmpty = totalSales < 1
        salesView.isHidden = salesEmpty
        
        if !salesEmpty {
            salesTotalLabel.text = "\(totalSales)"
        }
    }
    
    private func setupRatingView(_ rating: Double){
        let ratingEmpty = rating == 0
        ratingView.isHidden = ratingEmpty
        
        if !ratingEmpty {
            ratingLabel.text = "\(rating)"
        }
    }
}
