//
//  ProductItemCell.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol MyProductArchiveItemCellDelegate {
    func myPopView(textAddPost: String, textShareStory: String, textShareOther: String,textArchiveProduct: String, textEditProduct: String)
}

class ProductItemCell: UICollectionViewCell {
	
	// MARK: - Public Property
	
	var item: Product!
    var delegate: MyProductArchiveItemCellDelegate?
	
	var handleOption: (() -> Void)?
	
	lazy var imageView: UIImageView = {
		let image = UIImageView(frame: .zero)
		image.translatesAutoresizingMaskIntoConstraints = false
		image.layer.cornerRadius = 8
		image.backgroundColor = .gray
		image.clipsToBounds = true
		image.contentMode = .scaleAspectFill
		image.isUserInteractionEnabled = true
		return image
	}()
	
	let titleLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.medium, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 3)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let priceLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.bold, size: 12), textColor: .gradientStoryOne, textAlignment: .left, numberOfLines: 2)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.layer.masksToBounds = false
		return label
	}()
    
    var onMoreClick : () -> () = {}
	
//	lazy private var optionButton: UIButton = {
//		let button = UIButton(image: UIImage(named: String.get(.iconReport))!, target: self, action: #selector(handleOptionButton))
//		button.translatesAutoresizingMaskIntoConstraints = false
//		button.backgroundColor = .black
//		button.layer.masksToBounds = false
//		button.layer.cornerRadius = 32 / 2
//		button.layer.borderWidth = 1
//		button.layer.borderColor = UIColor.grey.cgColor
//		button.alpha = 0.8
//		return button
//	}()
    
    lazy private var optionMore: UIButton = {
        let button = UIButton(image: UIImage(named: String.get(.iconKebabEllipsis))!, target: self, action: #selector(handleOptionFavorite))
        return button
    }()
	
//	@objc func handleOptionButton() {
//		self.handleOption?()
//	}
    
    @objc func handleOptionFavorite() {
        onMoreClick()
    }

	// MARK: - Public Method
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .white
		
		addSubview(imageView)
		addSubview(titleLabel)
		addSubview(priceLabel)
		
		imageView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0)
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
		titleLabel.anchor(top: imageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 18)
		priceLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 18)
		let imageConstraint = imageView.bottomAnchor.constraint(greaterThanOrEqualTo: titleLabel.topAnchor, constant: 8)
		imageConstraint.priority = UILayoutPriority(750)
		imageConstraint.isActive = true
		
//		imageView.addSubview(optionButton)
//		optionButton.anchor(bottom: imageView.safeAreaLayoutGuide.bottomAnchor, right: imageView.safeAreaLayoutGuide.rightAnchor, paddingBottom: 12, paddingRight: 12, width: 32, height: 32)
        
        imageView.addSubview(optionMore)
        optionMore.anchor(bottom: imageView.safeAreaLayoutGuide.bottomAnchor, right: imageView.safeAreaLayoutGuide.rightAnchor, paddingBottom: 12, paddingRight: 12, width: 32, height: 32)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
//	func hideOptions(hide: Bool) {
//		self.optionButton.isHidden = hide
//	}
	
	func configure(_ item: Product) {
        imageView.loadImage(at: item.medias?.first?.thumbnail?.large ?? "", low: item.medias?.first?.thumbnail?.small ?? "", .w360, .w40)
		priceLabel.text = item.price?.toMoney() ?? "0".toMoney()
		titleLabel.text = item.name
		
        if let id = item.accountId {
            if id.isItUser() {
                optionMore.isHidden = false
            } else {
                optionMore.isHidden = true
            }
        }
	}
}

