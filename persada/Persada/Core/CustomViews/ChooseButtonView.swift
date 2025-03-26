//
//  ChooseButtonView.swift
//  Persada
//
//  Created by movan on 20/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ChooseButtonView: UIView {
	
	lazy var imageView: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFit
		image.isUserInteractionEnabled = true

		return image
	}()
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = ""
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.numberOfLines = 0
		return label
	}()
	
	lazy var priceLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = ""
		label.textColor = .primary
		return label
	}()
	
	lazy var chooseProductButton: UIButton = {
		let button = UIButton(type: .system)
		button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
		return button
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[imageView, titleLabel, priceLabel, chooseProductButton].forEach { (view) in
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}

		backgroundColor = .whiteSnow
		
		imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 16, paddingBottom: 8, paddingRight: 9, width: 50, height: 0)
		
		titleLabel.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 32, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
		
		priceLabel.anchor(top: titleLabel.bottomAnchor, left: imageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 32, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
		
		chooseProductButton.fillSuperview()
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func handleButton() {
		print("tesing product")
	}
}
