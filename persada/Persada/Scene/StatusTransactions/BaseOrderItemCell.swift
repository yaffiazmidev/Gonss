//
//  BaseOrderItemCell.swift
//  KipasKipas
//
//  Created by NOOR on 21/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class BaseOrderItemCell: UICollectionViewCell {
	
	var item: OrderCellViewModel!
	
	var handleTransaction: ((String, String, String?) -> Void)?
	
	lazy var iconImageView: UIImageView = {
		let imageView = UIImageView()
		let placeholderImage = UIImage(named: "placeholderUserImage")
		imageView.backgroundColor = .whiteSnow
		imageView.layer.cornerRadius = 4
		imageView.clipsToBounds = true
		imageView.image = placeholderImage
		return imageView
	}()
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = UIFont.Roboto(.bold, size: 14)
		return label
	}()
	
	lazy var priceLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = UIFont.Roboto(.medium, size: 12)
		label.numberOfLines = 0
		return label
	}()
	
	lazy var noInvoiceLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = UIFont.Roboto(.medium, size: 12)
		label.numberOfLines = 0
		return label
	}()
	
	lazy var containerView: UIView = {
		let view: UIView = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = false
		return view
	}()
	
	lazy var buttonPickUp: PrimaryButton = {
		let button = PrimaryButton(title: "", titleColor: .white, font: .Roboto(.bold, size: 14), backgroundColor: .primary, target: self, action: #selector(handleTransactionWhenTappedButton))
		return button
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .white
		addSubview(containerView)
		containerView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16)
		addShadow(shadowColor: .black, offSet: CGSize(width: 0, height: 5), opacity: 0.10, shadowRadius: 8, cornerRadius: 8, corners: .topRight, fillColor: .whiteSnow)

		[iconImageView, titleLabel, noInvoiceLabel, priceLabel, buttonPickUp].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		iconImageView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8, width: 35, height: 35)

		titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: iconImageView.rightAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 8, height: 20)

		priceLabel.anchor(top: titleLabel.bottomAnchor, left: iconImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 40)

		noInvoiceLabel.anchor(top: priceLabel.bottomAnchor, left: iconImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 30)

		buttonPickUp.anchor(top: noInvoiceLabel.bottomAnchor, left: leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
		
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func shouldButton(hide: Bool, with text: String) {
		self.buttonPickUp.isHidden = hide
		self.buttonPickUp.setTitle(text, for: .normal)
	}
	
	func setupOrder(item: OrderCellViewModel) {
		iconImageView.loadImage(at: item.urlProductPhoto )
		titleLabel.text = item.productName
		priceLabel.text = "\(item.cost.toMoney())"
		noInvoiceLabel.text = item.noInvoice
		self.item = item
	}
	
	@objc func handleTransactionWhenTappedButton() {
		let itemInvoice = item.orderStatus
		let itemPayment = item.paymentStatus
		let itemStatusLogistic = item.shipmentStatus ?? nil
		self.handleTransaction?(itemInvoice, itemPayment, itemStatusLogistic)
	}
}
