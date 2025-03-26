//
//  GopayView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class GopayView: UIView {
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel(text: "gopay", font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let saldoLabel: UILabel = {
		let label = UILabel(text: "0".toMoney(), font: .Roboto(.regular, size: 13), textColor: .grey, textAlignment: .left, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy var topUpButton: UIButton = {
		let button = UIButton(title: "Top Up", titleColor: .white, font: .Roboto(.regular, size: 13), backgroundColor: .success, target: self, action: #selector(handleTopUp))
		button.layer.masksToBounds = false
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 8
		return button
	}()
	
	@objc func handleTopUp() {
		print("handle top up / add account")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .clear
		titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
		saldoLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
		let stackView = UIStackView(arrangedSubviews: [titleLabel, saldoLabel])
		stackView.distribution = .fillProportionally
		stackView.spacing = 4
		stackView.axis = .vertical
		
		[stackView, topUpButton].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 8, width: 140)
		topUpButton.anchor(top: topAnchor, left: stackView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 8, paddingRight: 16)
	}
	
	func configure(value: String) {
		self.saldoLabel.text = value.toMoney()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
}
