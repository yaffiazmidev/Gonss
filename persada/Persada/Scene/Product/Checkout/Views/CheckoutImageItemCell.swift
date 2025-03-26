//
//  CheckoutImageItemCell.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CheckoutImageItemCell: UICollectionViewCell {
	
	lazy var imageView: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFit
		image.isUserInteractionEnabled = true
		
		return image
	}()
	
	lazy var titleLabel: UILabel = UILabel( font: .AirBnbCereal(.bold, size: 13), textColor: .black, textAlignment: .left, numberOfLines: 0)
	
	lazy var subtitleLabel: UILabel = UILabel(font: .AirBnbCereal(.book, size: 12), textColor: .primary, textAlignment: .left, numberOfLines: 0)
	
	func configure(imageURL: String, title: String, price: String) {
		imageView.loadImage(at: imageURL)
		titleLabel.text = title
		subtitleLabel.text = price
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[imageView, titleLabel, subtitleLabel].forEach { (view) in
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
		
		imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 16, paddingRight: 0, width: 50, height: 50)
		
		titleLabel.anchor(top: imageView.topAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 30)
		
		subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: imageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 16, paddingRight: 16, width: 0, height: 0)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
