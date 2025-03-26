//
//  ProductDetailView.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ProductDetailViewDelegate where Self: UIViewController {

	func buy(_ item: Product, _ total: Int)
}

final class ProductDetailViewOld: UIView {
	
	weak var delegate: ProductDetailViewDelegate?
	
	var item: Product?
	
	lazy var collectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.registerCustomReusableHeaderView(ProductDetailHeaderView.self)
		view.registerCustomCell(ProductDetailItemCellImage.self)
		view.registerCustomCell(ProductDetailItemCellTitle.self)
		view.registerCustomCell(DetailItemUsernameCell.self)
		view.registerCustomCell(DetailItemUsernameCell.self)
		view.registerCustomCell(DetailItemUsernameCell.self)
		view.registerCustomCell(DetailItemUsernameCell.self)
		view.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 110, right: 0)
		view.showsVerticalScrollIndicator = false
		view.backgroundColor = .white
		
		if #available(iOS 11.0, *) {
			view.contentInsetAdjustmentBehavior = .never
		}
		
		return view
	}()
	
	lazy var buyView: BuyButtonView = {
		let view = BuyButtonView()
		return view
	}()
	
	lazy var emptyLabel: UILabel = {
		let label: UILabel = UILabel()
		label.font = .AirBnbCereal(.book, size: 14)
		label.text = "Produk tidak dapat dibeli"
		label.textColor = .contentGrey
		label.textAlignment = .center
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[collectionView, buyView, emptyLabel].forEach { (view) in
			view.translatesAutoresizingMaskIntoConstraints = false
			view.backgroundColor = .white
			addSubview(view)
		}
		
		buyView.anchor(top: nil, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 64)
		
		collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: buyView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 16, paddingRight: 0, width: 0, height: 0)
		
		emptyLabel.anchor(top: nil, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
		
		buyView.handleBuy = {
			guard let validItem = self.item else {
				return
			}
			
			self.delegate?.buy(validItem, self.buyView.value)
		}
	}
	
	func updateView(isProductUser: Bool) {
		if isProductUser {
			buyView.isHidden = true
			emptyLabel.isHidden = false
		} else {
			buyView.isHidden = false
			emptyLabel.isHidden = true
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
