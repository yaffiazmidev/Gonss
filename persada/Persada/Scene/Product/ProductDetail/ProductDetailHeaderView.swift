//
//  ProductDetailHeaderView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

class ProductDetailHeaderView: UICollectionReusableView {
	
	lazy var label: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.bold, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .clear
		addSubview(label)
		label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
								 paddingTop: 10, paddingLeft: 16, paddingBottom: 10, paddingRight: 16)
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	@objc func handleWhenClickedShowButton() {
		
	}
}

