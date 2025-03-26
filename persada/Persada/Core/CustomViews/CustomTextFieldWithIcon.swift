//
//  CustomTextFieldWithIcon.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 12/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class CustomTextFieldWithIcon: UIView {
	
	// MARK: - Public Property
	
	var type: UIKeyboardType = .default
	var placeholder: String?{
		didSet {
			self.nameTextField.placeholder = placeholder
			self.nameTextField.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.regular, size: 14), NSAttributedString.Key.foregroundColor: UIColor.placeholder])
		}
	}
	
	lazy var iconImage: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	lazy var nameTextField: CustomIndentedTextField = {
		let tf :CustomIndentedTextField = CustomIndentedTextField(placeholder: placeholder, padding: 15, cornerRadius: 5, keyboardType: type, isSecureTextEntry: false, borderWidth: 1, borderColor: .gainsboro)
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.contentVerticalAlignment = .center
		tf.font = .Roboto(.medium, size:14)
		tf.textColor = .black
		tf.tintColor = .black
		return tf
	}()
	
	let viewFrame = UIView(frame: .zero)
	
	// MARK: - Public Method
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}
	
	func setupView() {
		addSubview(viewFrame)
		viewFrame.translatesAutoresizingMaskIntoConstraints = false
		viewFrame.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
		
		viewFrame.addSubview(iconImage)
		viewFrame.addSubview(nameTextField)
		
		iconImage.anchor(left: viewFrame.leftAnchor, paddingLeft: 0, width: 30, height: 30)
		iconImage.centerYToSuperview()
		nameTextField.anchor(top: viewFrame.topAnchor, left: iconImage.rightAnchor, bottom: viewFrame.bottomAnchor, right: viewFrame.rightAnchor, paddingTop: 5, paddingLeft: 16, paddingBottom: 5, paddingRight: 0)
		nameTextField.centerYToSuperview()
	}
	
	func textFieldIsEmpty() -> Bool  {
		if nameTextField.text?.isEmpty ?? false {
			return false
		} else {
			return true
		}
	}
	
}




