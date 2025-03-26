//
//  DetailItemUsernameTableViewCell.swift
//  KipasKipas
//
//  Created by movan on 14/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class DetailItemUsernameTableViewCell: UITableViewCell {
	
	var handler: (() -> Void)?
	
	let descriptionLabel: UILabel = {
		let label: UILabel = UILabel()
		label.backgroundColor = .white
		label.textColor = UIColor.black
		label.font = UIFont.Roboto(.regular, size: 16)
		label.isUserInteractionEnabled = true
		label.numberOfLines = 0
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .white
		
		addSubview(descriptionLabel)

		descriptionLabel.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
	}
	
	func configure(_ name: String, _ isUsername: Bool) {
		descriptionLabel.text = name
		
		if isUsername {
			descriptionLabel.textColor = .secondary
			let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedLabel))
			descriptionLabel.addGestureRecognizer(imageTapGesture)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func handleWhenTappedLabel() {
		self.handler?()
	}
}
