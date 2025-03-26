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
	
	private let descriptionLabel: UITextView = {
		let label = UITextView(text: "", font: UIFont.Roboto(.regular, size: 16), textColor: UIColor.black, textAlignment: NSTextAlignment.left)
		label.backgroundColor = .white
		label.isUserInteractionEnabled = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		contentView.addSubview(descriptionLabel)

		descriptionLabel.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
	}
	
	func configure(_ name: String, _ isUsername: Bool) {
		
		if isUsername {
			descriptionLabel.text = "@\(name)"
			descriptionLabel.textColor = .secondary
			let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedLabel))
			descriptionLabel.addGestureRecognizer(imageTapGesture)
		} else {
			descriptionLabel.text = name
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	@objc private func handleWhenTappedLabel() {
		self.handler?()
	}
}

