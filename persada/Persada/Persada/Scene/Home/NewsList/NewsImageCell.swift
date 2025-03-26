//
//  NewsImageCell.swift
//  KipasKipas
//
//  Created by movan on 24/11/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class NewsImageCell: UICollectionViewCell {
	
	// MARK: - Public  Property
	
	var item: String! {
		didSet {
			imageStory.loadImage(at: item ?? "")
		}
	}
	
	var handleDetailStory: ((_ id: String, _ account: Profile, _ postStories: [Stories], _ imageURL: String) -> Void)?
	
	let gradientLayer = CAGradientLayer()

	lazy var imageStory: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFit
		image.layer.masksToBounds = false
		image.layer.cornerRadius = 16
		image.isUserInteractionEnabled = true
		return image
	}()

	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .white
		label.backgroundColor = .init(hexString: "#4A4A4A", alpha: 0.9)
		label.layer.masksToBounds = false
		label.layer.cornerRadius = 8
		label.font = .AirBnbCereal(.bold, size: 14)
		label.numberOfLines = 0
		label.clipsToBounds = true
		label.textAlignment = .center
		return label
	}()
	
	lazy var sourceLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = ""
		label.textColor = .placeholder
		label.backgroundColor = .white
		label.font = .AirBnbCereal(.book, size: 10)
		label.numberOfLines = 0
		return label
	}()
	
	// MARK: - Public Method
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		backgroundColor = .white

		[imageStory, sourceLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		imageStory.addSubview(titleLabel)

		sourceLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 20)
		imageStory.anchor(top: sourceLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 230)
		
		titleLabel.anchor(top: nil, left: imageStory.leftAnchor, bottom: bottomAnchor, right: imageStory.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 20, paddingRight: 16, width: 0, height: 70)
	}
	
	func set(source: String, imageURL: String, title: String) {
		imageStory.loadImage(at: imageURL)
		sourceLabel.text = "source - \(source)"
		titleLabel.text = title
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		gradientLayer.frame = bounds
	}
	
	@objc func handleWhenTappedImageStory() {
	}
	
}


