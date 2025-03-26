//
//  ChannelContentsHeaderView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ChannelContentsHeaderView: UITableViewHeaderFooterView {
	
	var handlerFollow: (() -> Void)?
	
	var messageLabel: UILabel = {
		let lbl = UILabel(font: .Roboto(.regular, size: 12), textColor: .contentGrey, textAlignment: .center, numberOfLines: 0)
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()
	
	lazy var buttonFollow: BadgedButton = {
		let button = BadgedButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 8
		button.layer.masksToBounds = false
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .primary
		button.titleLabel?.font = .Roboto(.medium, size: 12)
		button.setTitle(.get(.follow), for: .normal)
		button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
		return button
	}()
	
	@objc func handleFollow() {
		self.handlerFollow?()
	}

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .white
		
		contentView.addSubview(messageLabel)
		contentView.addSubview(buttonFollow)
		
		messageLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 8)
		messageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
		buttonFollow.anchor(top: messageLabel.bottomAnchor, bottom: contentView.bottomAnchor, paddingTop: 8, paddingBottom: 8, width: 80, height: 30)
		buttonFollow.centerXToSuperview()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
}
