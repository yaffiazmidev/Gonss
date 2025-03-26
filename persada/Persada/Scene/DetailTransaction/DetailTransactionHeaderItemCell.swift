//
//  DetailTransactionHeaderItemCell.swift
//  KipasKipas
//
//  Created by movan on 14/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class DetailTransactionHeaderItemCell: UITableViewCell {
	
	private enum ViewTrait {
		static let padding: CGFloat = 16
	}
	
	lazy var iconImageView: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFit
		image.isUserInteractionEnabled = true
		image.backgroundColor = .white
		image.layer.masksToBounds = true
		image.layer.cornerRadius = 8
		return image
	}()
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.bold, size: 13), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.backgroundColor = .white
		return label
	}()
	
	lazy var subtitleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .gray
		label.backgroundColor = .white
		label.font = UIFont.Roboto(.regular, size: 12)
		return label
	}()
	
	lazy var label: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .gray
		label.backgroundColor = .white
		label.font = UIFont.Roboto(.regular, size: 12)
		return label
	}()
	
	func configure(imageURL: String, title: String, price: String, quantity: String) {
		iconImageView.loadImage(at: imageURL)
		titleLabel.text = title
		subtitleLabel.text = price
		label.text = "\(quantity) pcs"
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .white
		
		[iconImageView, titleLabel, subtitleLabel, label].forEach { (view) in
			view.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(view)
		}
		
		iconImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 8, paddingLeft: ViewTrait.padding, width: 72, height: 72)
		
		titleLabel.anchor(top: contentView.topAnchor, left: iconImageView.rightAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: ViewTrait.padding, paddingRight: ViewTrait.padding)
		titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
		
		subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: iconImageView.rightAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: ViewTrait.padding, paddingRight: ViewTrait.padding)
		
		label.anchor(top: subtitleLabel.bottomAnchor, left: iconImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: ViewTrait.padding, paddingBottom: ViewTrait.padding * 2, paddingRight: ViewTrait.padding)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}


