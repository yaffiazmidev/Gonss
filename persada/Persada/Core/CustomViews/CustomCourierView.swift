//
//  CustomCourierView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class CustomCourierView: UIView {
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.bold, size: 13), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy var subtitleLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let priceLabel: UILabel = {
		let label = UILabel(font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .right, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	
		addSubview(priceLabel)
		addSubview(titleLabel)
		addSubview(subtitleLabel)
		
		priceLabel.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 12, paddingBottom: 12, paddingRight: 12, width: 80)
		
		titleLabel.anchor(top: topAnchor, left: leftAnchor, right: priceLabel.leftAnchor, paddingTop: 8, paddingLeft: 4, paddingRight: 4)
		subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: titleLabel.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 8, paddingRight: 0)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(title: String, subtitle: String, price: String) {
		
		titleLabel.text = title
		subtitleLabel.text = subtitle
		priceLabel.text = price
	}
}


