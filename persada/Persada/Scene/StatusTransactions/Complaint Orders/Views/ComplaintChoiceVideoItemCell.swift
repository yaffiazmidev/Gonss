//
//  ComplaintChoiceVideoItemCell.swift
//  KipasKipas
//
//  Created by NOOR on 02/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

final class ComplaintChoiceVideoItemCell: UITableViewCell {
	
	let gradientLayer = CAGradientLayer()
	
	lazy var iconImageView: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.layer.masksToBounds = true
		image.isUserInteractionEnabled = true
		image.layer.cornerRadius = 8
		let imageTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.handleAddMedia))
				image.addGestureRecognizer(imageTapGesture)
		return image
	}()

	// MARK: - Public Method
	
	var handleMedia: (() -> Void)?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .white
		
		let size = frame.width / 3 - 16
		// TableViewCell should use 'contentView'
		contentView.addSubview(iconImageView)
		iconImageView.centerYTo(contentView.centerYAnchor)
		iconImageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        iconImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	@objc func handleAddMedia() {
		self.handleMedia?()
	}
}

