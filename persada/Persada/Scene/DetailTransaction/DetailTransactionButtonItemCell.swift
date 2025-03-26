//
//  DetailTransactionButtonItemCell.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class DetailTransactionButtonItemCell: UITableViewCell {

	// MARK: - Private Propperty

	private enum ViewTrait {
		static let padding: CGFloat = 16
	}
	
	// MARK: - Public Propperty
	
	lazy var mainButton: PrimaryButton = {
		let button = PrimaryButton(type: .custom)
		button.setup(color: .primary, textColor: .white, font: UIFont.Roboto(.bold, size: 14))
		button.addTarget(self, action: #selector(handlerWhenTappedButton), for: .touchUpInside)
		return button
	}()
	
	lazy var secondaryButton: PrimaryButton = {
		let button =  PrimaryButton(type: .custom)
		button.setup(color: .whiteSnow, textColor: .grey, font: .Roboto(.bold, size: 14))
		button.addTarget(self, action: #selector(handleSecondaryButton), for: .touchUpInside)
		return button
	}()
	
	var handler: (() -> Void)?
	var secondaryHandler: (() -> Void)?
	
	// MARK:- Public Methods
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.backgroundColor = .white
		self.contentView.backgroundColor = .white
		[mainButton, secondaryButton].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview($0)
		}

		mainButton.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 50)
		secondaryButton.anchor(top: mainButton.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 16, paddingBottom: 10, paddingRight: 16, width: 0, height: 50)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(firstText: String, secondText: String) {
		mainButton.setTitle(firstText, for: .normal)
		secondaryButton.setTitle(secondText, for: .normal)
		mainButton.isHidden = firstText == "" ? true : false
		secondaryButton.isHidden = secondText == "" ? true : false
	}
	
	@objc private func handlerWhenTappedButton() {
		self.handler?()
	}
	
	@objc func handleSecondaryButton() {
		self.secondaryHandler?()
	}
}
