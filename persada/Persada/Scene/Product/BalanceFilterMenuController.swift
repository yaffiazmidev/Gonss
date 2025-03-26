//
//  BalanceFilterMenuController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 04/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BalanceFilterMenuController: UIViewController {
	
	let titleLabel = UILabel(text: .get(.filter), font: .Roboto(.regular, size: 16), textColor: .black, textAlignment: .left, numberOfLines: 1)
	
	let subtitleLabel =  UILabel(text: .get(.filter3Month), font: .Roboto(.regular, size: 12), textColor: .primary, textAlignment: .left, numberOfLines: 0)
	
	lazy var dateFromView: CustomDatePicker = {
		let customView = CustomDatePicker(frame: .zero)
		customView.placeholder = .get(.datePlaceholder)
		customView.title = .get(.dariTanggal)
		customView.translatesAutoresizingMaskIntoConstraints = false
		customView.nameTextField.layer.masksToBounds = false
		customView.nameTextField.layer.cornerRadius = 8
		customView.nameTextField.layer.borderWidth = 1
		customView.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		
		return customView
	}()
	
	lazy var dateAfterView: CustomDatePicker = {
		let customView = CustomDatePicker(frame: .zero)
		customView.placeholder = .get(.datePlaceholder)
		customView.title = .get(.sampaiTanggal)
		customView.translatesAutoresizingMaskIntoConstraints = false
		customView.nameTextField.layer.masksToBounds = false
		customView.nameTextField.layer.cornerRadius = 8
		customView.nameTextField.layer.borderWidth = 1
		customView.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		
		return customView
	}()
	
	var debitOrCreditView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		let title = UILabel(text: .get(.typeOfTransaction), font: .Roboto(.regular, size: 13), textColor: .contentGrey, textAlignment: .left, numberOfLines: 0)
		var uangMasukButton = PrimaryButton(title: .get(.uangMasuk), titleColor: .secondary, font: .Roboto(.regular, size: 13), backgroundColor: .secondaryLowTint, target: self, action: #selector(handleUangMasuk))
		var penarikanButton = PrimaryButton(title: .get(.penarikan), titleColor: .grey, font: .Roboto(.regular, size: 13), backgroundColor: .whiteSmoke, target: self, action: #selector(handlePenarikan))
		
		view.addSubview(title)
		title.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 16)
		
		let stackView = UIStackView(arrangedSubviews: [uangMasukButton, penarikanButton])
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.alignment = .fill
		stackView.spacing = 8
		
		view.addSubview(stackView)
		stackView.anchor(top: title.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
		
		return view
	}()
	
	lazy var confirmFilterButton: PrimaryButton = {
		let button = PrimaryButton(title: .get(.implmentedFilter), titleColor: .white, font: .Roboto(.regular, size: 13), backgroundColor: .secondary, target: self, action: #selector(handleFilter))
		return button
	}()
	
	lazy var dateStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [dateFromView, dateAfterView])
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.alignment = .fill
		stackView.spacing = 8
		return stackView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		dateFromView.heightAnchor.constraint(equalToConstant: 60).isActive = true
		dateAfterView.heightAnchor.constraint(equalToConstant: 60).isActive = true
		preferredContentSize = CGSize(width: 250, height: 370)
		
		view.addSubview(titleLabel)
		view.addSubview(subtitleLabel)
		view.addSubview(dateStackView)
		view.addSubview(debitOrCreditView)
		view.addSubview(confirmFilterButton)
		
		titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 24, paddingLeft: 24, paddingRight: 24, height: 25)
		
		subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 24, paddingLeft: 24, paddingRight: 24, height: 30)
		
		dateStackView.anchor(top: subtitleLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 24, paddingLeft: 24, paddingRight: 24, height: 70)
		
		debitOrCreditView.anchor(top: dateStackView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 16, paddingLeft: 24, paddingRight: 24, height: 70)
		
		confirmFilterButton.anchor(top: debitOrCreditView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 16, paddingLeft: 24, paddingRight: 24, height: 40)
		confirmFilterButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 24).isActive = true
		
	}
	
	@objc private func handleFilter() {
		self.dismiss(animated: false)
	}
	
	@objc private func handleUangMasuk() {
		
	}

	@objc private func handlePenarikan() {
		
	}
}

