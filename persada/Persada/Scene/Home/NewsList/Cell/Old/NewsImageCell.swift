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
		image.contentMode = .scaleAspectFill
		image.layer.masksToBounds = true
		image.layer.cornerRadius = 8
		image.isUserInteractionEnabled = true
		return image
	}()

	lazy var titleLabel: PaddingLabel = {
		let label: PaddingLabel = PaddingLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .white
		label.backgroundColor = UIColor.greyAlpha9
		label.layer.masksToBounds = false
		label.layer.cornerRadius = 8
		label.font = .Roboto(.bold, size: 18)
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
		label.font = .Roboto(.regular, size: 10)
		label.numberOfLines = 0
		return label
	}()
	
	lazy var newLabel : PaddingLabel = {
		let label: PaddingLabel = PaddingLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .white
		label.backgroundColor = UIColor.greenKelly
		label.layer.masksToBounds = false
		label.font = .Roboto(.bold, size: 14)
		label.numberOfLines = 0
		label.clipsToBounds = true
		label.textAlignment = .center
		label.text = String.get(.new)
		return label
	}()
	
	// MARK: - Public Method
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		backgroundColor = .white

		[imageStory, sourceLabel, titleLabel, newLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		
		sourceLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, height: 20)
		newLabel.anchor(top: sourceLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 30,  paddingLeft: 20)
		imageStory.anchor(top: sourceLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, height: 230)
		
		titleLabel.anchor(top: imageStory.bottomAnchor, left: imageStory.leftAnchor, bottom: bottomAnchor, right: imageStory.rightAnchor, paddingTop: -40, paddingLeft: 16, paddingBottom: 20, paddingRight: 16, height: 70)
	}
	
	func setUpCell(source: String, imageURL: String, title: String) {
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

