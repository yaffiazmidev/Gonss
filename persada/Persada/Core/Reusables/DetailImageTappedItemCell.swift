//
//  DetailImageTappedItemCell.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class DetailImageTappedItemCell: UITableViewCell {

	var handler: (() -> Void)?
	
	private enum ViewTrait {
		static let padding: CGFloat = 16
	}
	
	lazy var customLabel: CustomImageTappedLabel = {
		let view = CustomImageTappedLabel()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .whiteSnow
		view.isUserInteractionEnabled = true
		view.layer.masksToBounds = false
		view.layer.cornerRadius = 8
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
		view.addGestureRecognizer(gesture)
		return view
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .white
		addSubview(customLabel)
		customLabel.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: ViewTrait.padding, left: ViewTrait.padding, bottom: ViewTrait.padding, right: ViewTrait.padding))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func handleGesture() {
		self.handler?()
	}
}

class CustomImageTappedLabel: UIView {
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textAlignment = .center
		label.backgroundColor = .clear
		label.font = UIFont.Roboto(.regular, size: 13)
		label.textColor = .black
		return label
	}()
	
	lazy var imageView: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFit
		image.backgroundColor = .clear
		return image
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .clear
		[titleLabel, imageView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingTop: 8, paddingLeft:  8, paddingBottom: 8, width: 50)
		titleLabel.anchor(left: imageView.rightAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 8, height:  40)
		titleLabel.centerYTo(centerYAnchor)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(texts: String, colors: UIColor, imageURL: String, type: String) {
		
		let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "\(texts )", attributes: [NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 13), NSAttributedString.Key.foregroundColor: colors ])
		
		let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 8
		attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
		
		titleLabel.attributedText = attributedText
		titleLabel.numberOfLines = 0
		
		if imageURL != "" {
			imageView.loadImage(at: imageURL)
		} else {
			if type == "donation" {
				imageView.image = UIImage(named: "iconRumahZakat")
			} else if (type == "product") {
				imageView.image = UIImage(named: "iconbca")
			}
			
		}
		
	}
}


