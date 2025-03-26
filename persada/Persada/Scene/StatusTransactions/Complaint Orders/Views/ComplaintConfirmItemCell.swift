//
//  ComplaintConfirmItemCell.swift
//  KipasKipas
//
//  Created by NOOR on 02/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ComplaintConfirmItemCell: UITableViewCell {
	
	// MARK: - Public Propperty
	
	lazy var mainButton: PrimaryButton = {
		let button = PrimaryButton(type: .custom)
		button.setup(color: .whiteSmoke, textColor: .white, font: UIFont.Roboto(.bold, size: 14))
		button.setTitle("Kirim Komplain", for: .normal)
		button.addTarget(self, action: #selector(handlerWhenTappedButton), for: .touchUpInside)
		return button
	}()
	
	var handler: (() -> Void)?
	
	// MARK:- Public Methods
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.backgroundColor = .white
		self.contentView.backgroundColor = .white

		mainButton.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(mainButton)

        mainButton.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
//		mainButton.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(enable: Bool) {
		mainButton.isValid = enable
	}
	
	@objc private func handlerWhenTappedButton() {
		self.handler?()
	}
}

