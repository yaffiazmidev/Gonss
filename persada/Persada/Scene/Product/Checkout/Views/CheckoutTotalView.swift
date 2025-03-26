//
//  CheckoutTotalView.swift
//  Persada
//
//  Created by movan on 27/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CheckoutTotalView: UIView {

	lazy var subtotalLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.text = "3x Rp 90.000"
		return label
	}()
	
	lazy var subtotalText: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.text = "Subtotal"
		return label
	}()
	
	lazy var shippingCostLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Rp 50.000"
		return label
	}()
	
	lazy var shippingCostText: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Biaya Kirim"
		return label
	}()
	
	lazy var totalLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Rp 270.000"
		label.font = UIFont.boldSystemFont(ofSize: 14)
		return label
	}()
	
	lazy var totalText: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Total"
		label.font = UIFont.boldSystemFont(ofSize: 14)
		return label
	}()
	
	lazy var checkoutButton: PrimaryButton = {
		let button = PrimaryButton(type: .system)
		button.setTitle("Metode Pembayaran", for: .normal)
		button.setTitleColor(.white, for: .normal)

		return button
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let width = UIScreen.main.bounds.width - 16
		
		[subtotalLabel, subtotalText, shippingCostLabel, shippingCostText, totalLabel, totalText].forEach {
			$0.textColor = .black
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		addSubview(checkoutButton)
		
		subtotalText.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 30)
		subtotalLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: subtotalText.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
		
		shippingCostText.anchor(top: subtotalText.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 30)
		
		shippingCostLabel.anchor(top: subtotalLabel.bottomAnchor, left: shippingCostText.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
		
		totalText.anchor(top: shippingCostText.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 30)
		
		totalLabel.anchor(top: shippingCostLabel.bottomAnchor, left: totalText.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
		
		checkoutButton.anchor(top: totalText.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
