//
//  ProfileSettingAccountView.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol ProfileSettingAccountViewDelegate where Self: UIViewController {

	func sendDataBackToParent(_ data: Data)
}

final class ProfileSettingAccountView: UIView {

	weak var delegate: ProfileSettingAccountViewDelegate?
    
	private enum ViewTrait {
		static let leftMargin: CGFloat = 10.0
		static let paddingTop: CGFloat = 32.0
		static let paddingLeft: CGFloat = 34.0
		static let paddingRight: CGFloat = 34.0
	}

	lazy var usernameCustomTextField : CustomTextFieldWithError = {
		var customTextField: CustomTextFieldWithError = CustomTextFieldWithError()
        customTextField.nameLabel.text = StringEnum.username.rawValue
		customTextField.nameLabel.textColor = .grey
        customTextField.textField.layer.cornerRadius = 8
        customTextField.setInActive()
		customTextField.draw(.zero)
		return customTextField
	}()

	lazy var emailCustomTextField : CustomTextFieldWithError = {
		var customTextField: CustomTextFieldWithError = CustomTextFieldWithError()
		customTextField.nameLabel.text = StringEnum.email.rawValue
		customTextField.nameLabel.textColor = .grey
		customTextField.textField.layer.cornerRadius = 8
        customTextField.textField.keyboardType = UIKeyboardType.emailAddress
        customTextField.setInActive()
        customTextField.draw(.zero)
		return customTextField
	}()

	lazy var phoneCustomTextField : CustomTextFieldWithError = {
		var customTextField: CustomTextFieldWithError = CustomTextFieldWithError()
		customTextField.nameLabel.text = StringEnum.phone.rawValue
		customTextField.nameLabel.textColor = .grey
        customTextField.textField.layer.cornerRadius = 8
        customTextField.setInActive()
		customTextField.draw(.zero)
		return customTextField
	}()
    
    lazy var backgroundOrange : UIView = {
        let view = UIView()
        view.backgroundColor = .primaryLowTint
        return view
    }()
    
    lazy var infoLabelTitle : UILabel = {
        let label = UILabel(text: "Ubah Data Akun", font: .Roboto(.medium, size: 14), textColor: .primary, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var infoLabelDesc : UILabel = {
        let label = UILabel(text: "Mohon bersabar ya, kami sedang berusaha untuk menghadirkan fitur ubah informasi akun untuk kamu.", font: .Roboto(.medium, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 0)
        return label
    }()

	override func draw(_ rect: CGRect) {

		addSubview(usernameCustomTextField)
		addSubview(emailCustomTextField)
		addSubview(phoneCustomTextField)
        addSubview(backgroundOrange)

		usernameCustomTextField.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.paddingTop, paddingLeft: ViewTrait.paddingLeft, paddingRight: ViewTrait.paddingRight)

		emailCustomTextField.anchor(top: usernameCustomTextField.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.paddingTop, paddingLeft: ViewTrait.paddingLeft, paddingRight: ViewTrait.paddingRight)

		phoneCustomTextField.anchor(top: emailCustomTextField.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.paddingTop, paddingLeft: ViewTrait.paddingLeft, paddingRight: ViewTrait.paddingRight)
        
        backgroundOrange.anchor(top: phoneCustomTextField.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.paddingTop, paddingLeft: ViewTrait.paddingLeft, paddingRight: ViewTrait.paddingRight)
        backgroundOrange.layer.cornerRadius = 8
        backgroundOrange.isHidden = true
        
        backgroundOrange.addSubview(infoLabelTitle)
        backgroundOrange.addSubview(infoLabelDesc)
        
        infoLabelTitle.anchor(top: backgroundOrange.topAnchor, left: backgroundOrange.leftAnchor, right: backgroundOrange.rightAnchor, paddingTop: 24, paddingLeft: 24, paddingRight: 24)
        infoLabelDesc.anchor(top: infoLabelTitle.bottomAnchor, left: backgroundOrange.leftAnchor, bottom: backgroundOrange.bottomAnchor, right: backgroundOrange.rightAnchor, paddingTop: 14, paddingLeft: 24, paddingBottom: 24, paddingRight: 24)
        
	}
    
    
}
