//
//  ProductDetailItemCellTitle.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ProductDetailItemCellTitle: UICollectionViewCell {
	
	let itemNameLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.bold, size: 17), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy var itemPriceTextView: UITextView = {
		var text: UITextView = UITextView(text: "", font: .Roboto(.regular, size: 13), textColor: .primary, textAlignment: .left)
		text.backgroundColor = .white
		text.isUserInteractionEnabled = false
		text.translatesAutoresizingMaskIntoConstraints = false
		return text
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(itemNameLabel)
		addSubview(itemPriceTextView)
		
		itemNameLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16, width: 0, height: 40)
		itemPriceTextView.anchor(top: itemNameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 16, paddingRight: 16, width: 0, height: 0)
	}
	
	func configure(price: String, name: String) {
		itemNameLabel.text = name
		itemPriceTextView.text = price
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}


