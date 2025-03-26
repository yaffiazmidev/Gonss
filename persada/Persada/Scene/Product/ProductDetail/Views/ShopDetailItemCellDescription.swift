//
//  DetailItemUsernameCell.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class DetailItemUsernameCell: UICollectionViewCell {
	
	var handler: (() -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(descriptionLabel)

		descriptionLabel.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
	}
	
	func configure(_ name: String, _ isUsername: Bool) {
		descriptionLabel.text = name
		
		if isUsername {
			descriptionLabel.textColor = .secondary
			let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedLabel))
			descriptionLabel.addGestureRecognizer(imageTapGesture)
		}
	}
	
	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.black
		label.font = UIFont.AirbnbCereal(.regular, size: 16)
		label.isUserInteractionEnabled = true
		label.numberOfLines = 0
		return label
	}()
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func handleWhenTappedLabel() {
		self.handler?()
	}
}

