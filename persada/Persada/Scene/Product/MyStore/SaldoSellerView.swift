//
//  SaldoSellerView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class SaldoSellerView: UIView {
	
	lazy var titleLabel: UILabel = {
		let label = UILabel(text: "", font: .Roboto(.medium, size: 11), textColor: .grey, textAlignment: .left, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy var saldoLabel: UILabel = {
		let label = UILabel(text: "0".toMoney(), font: .Roboto(.bold, size: 14), textColor: .contentGrey, textAlignment: .left, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(titleLabel)
		addSubview(saldoLabel)
		
		titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 0, paddingRight: 8, width: 0, height: 20)
		
		saldoLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 10, paddingRight: 8)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func setup(title: String, saldo: String) {
		self.titleLabel.text = title
		self.saldoLabel.text = saldo
	}
}
