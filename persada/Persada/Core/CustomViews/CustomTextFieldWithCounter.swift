//
//  CustomTextFieldWithCounter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/09/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class CustomTextFieldWithCounter: UIView {
	
	// MARK: - Public Property
	
	var type: UIKeyboardType = .default
	var placeholder: String?{
		didSet {
			self.nameTextField.placeholder = placeholder
					self.nameTextField.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.regular, size: 12), NSAttributedString.Key.foregroundColor: UIColor.placeholder])
			print(placeholder ?? "")
		}
	}
	var title: String = "" {
		didSet {
			self.nameLabel.text = title
		}
	}
	var titleColor: String = ""
	
	lazy var nameLabel: UILabel = {
		let label = UILabel(text: title, font: .Roboto(.medium, size:12), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .placeholder
		return label
	}()
	
	lazy var nameTextField: DRHTextFieldWithCharacterCount = {
		let tf: DRHTextFieldWithCharacterCount = DRHTextFieldWithCharacterCount(placeholder: placeholder, padding: 15, cornerRadius: 5, keyboardType: type, isSecureTextEntry: false, borderWidth: 1, borderColor: .gainsboro)
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.contentVerticalAlignment = .top
		tf.font = .Roboto(.medium, size:14)
		tf.textColor = .black
		tf.tintColor = .black
		tf.lengthLimit = 100
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
	}
	
	func setupView() {
		addSubview(viewFrame)
		viewFrame.translatesAutoresizingMaskIntoConstraints = false
		viewFrame.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
		
		viewFrame.addSubview(nameLabel)
		viewFrame.addSubview(nameTextField)
		
		nameLabel.anchor(top: viewFrame.topAnchor, left: viewFrame.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
		
		nameTextField.anchor(top: nameLabel.bottomAnchor, left: viewFrame.leftAnchor, bottom: viewFrame.safeAreaLayoutGuide.bottomAnchor, right: viewFrame.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 5, paddingRight: 0)
		
		if !self.titleColor.isEmpty{
			nameLabel.textColor = UIColor(hexString: self.titleColor)
		}
	}
	
	override func draw(_ rect: CGRect) {
		super .draw(rect)
		
	}
	
	func textFieldIsEmpty() -> Bool  {
		if nameTextField.text?.isEmpty ?? false {
			return false
		} else {
			return true
		}
	}
	
}




