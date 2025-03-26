//
//  CustomSelectButton.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 25/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CustomSelectView : UIView {

	let rightImage: UIImageView
	var name: UILabel

	required init(name: String, rightImage: UIImage?, radius: CGFloat = 8, borderWidth: CGFloat = 1, borderColor: UIColor = .whiteSmoke) {

		self.name = UILabel(text: name, font: .Roboto(.medium, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
		self.rightImage = UIImageView(image: rightImage)

		super.init(frame: .zero)

		self.layer.borderWidth = borderWidth
		self.layer.borderColor = borderColor.cgColor
		self.layer.cornerRadius = radius
		draw(.zero)
	}

	required init?(coder: NSCoder) {
		 fatalError("init(coder:) has not been implemented")
	}

	override func draw(_ rect: CGRect) {
		addSubview(name)
		name.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingLeft: 16)

		if self.rightImage.image != nil {
			addSubview(self.rightImage)
			rightImage.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 12)
		}
	}
}
