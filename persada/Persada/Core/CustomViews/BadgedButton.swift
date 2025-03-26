//
//  BadgedButton.swift
//  Persada
//
//  Created by Muhammad Noor on 12/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

internal struct Constants {
	internal static let badgedCountLabelHPadding: CGFloat = 6
	internal static let badgedCountLabelVPadding: CGFloat = 2
	internal static let badgedCountLabelYOffset: CGFloat = 3
	internal static let badgedCountLabelFontSize: CGFloat = 12
    internal static let TEXT_FIELD_HSPACE: CGFloat = 6.0
    internal static let MINIMUM_TEXTFIELD_WIDTH: CGFloat = 56.0
    internal static let STANDARD_ROW_HEIGHT: CGFloat = 25.0
}

class BadgedButton: UIButton {
	
	private let badgedCountLabel = BadgedCountLabel()
	
	var count: Int = 0 {
		didSet {
			badgedCountLabel.isHidden = (count == 0)
			badgedCountLabel.count = count
			self.setNeedsLayout()
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if imageView != nil {
			imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
			titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
		}
		
		let size = badgedCountLabel.sizeThatFits(bounds.size)
		let badgedCountLabelSize = CGSize(width: size.width + 2 * Constants.badgedCountLabelHPadding, height: size.height + 2 * Constants.badgedCountLabelVPadding)
		let badgedCountLabelOrigin = CGPoint(x: bounds.maxX - badgedCountLabelSize.width / 2, y: -Constants.badgedCountLabelYOffset)
		badgedCountLabel.frame = CGRect(origin: badgedCountLabelOrigin, size: badgedCountLabelSize)
	}
	
	private func commonInit() {
		addSubview(badgedCountLabel)
		badgedCountLabel.isHidden = true
		if let fontName = self.titleLabel?.font.fontName {
			badgedCountLabel.font = UIFont(name: fontName, size: Constants.badgedCountLabelFontSize)
		}
		badgedCountLabel.isUserInteractionEnabled = false
		self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
	}
	
	func moveImageLeftTextCenter(imagePadding: CGFloat = 30.0){
		guard let imageViewWidth = self.imageView?.frame.width else{return}
		guard let titleLabelWidth = self.titleLabel?.intrinsicContentSize.width else{return}
		self.contentHorizontalAlignment = .right
		imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0, bottom: 0.0, right: 0.0)
		titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0, bottom: 0.0, right: (bounds.width - titleLabelWidth) / 2 - imageViewWidth)
	}
	
	func setup(color: UIColor = .primary, textColor: UIColor = .white, font: UIFont = .Roboto(.bold, size: 16)) {
		self.layer.cornerRadius = 8
		self.backgroundColor = color
		self.titleLabel?.font = font
		self.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
		self.setTitleColor(textColor, for: .normal)
		
	}
}
