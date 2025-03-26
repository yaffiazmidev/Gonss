//
//  NewsCategoryCell.swift
//  KipasKipas
//
//  Created by movan on 24/11/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class NewsCategoryCell: UICollectionViewCell {
	
	lazy var titleLabel: UILabel = {
		let label = UILabel(text: "", font: .AirBnbCereal(.book, size: 10), textColor: .grey, textAlignment: .center, numberOfLines: 2)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(titleLabel)
		titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
