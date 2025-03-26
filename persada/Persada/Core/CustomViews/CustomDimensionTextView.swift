//
//  CustomTextField.swift
//  Persada
//
//  Created by Muhammad Noor on 03/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CustomDimensionTextView: UIView {
	
	// MARK: - Public Property
	
	lazy var nameLabel: UILabel = {
		let label = UILabel(text: "Dimensi", font: .systemFont(ofSize: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy var lengthTextField: CustomIndentedTextField = {
		let tf :CustomIndentedTextField = CustomIndentedTextField(placeholder: "Panjang (cm)", padding: 10, cornerRadius: 5, keyboardType: .default, backgroundColor: .init(hexString: "#FAFAFA"), isSecureTextEntry: false)
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.font = UIFont.systemFont(ofSize: 14)
		tf.textColor = .black
		return tf
	}()
	
	lazy var widthTextField: CustomIndentedTextField = {
		let tf :CustomIndentedTextField = CustomIndentedTextField(placeholder: "Lebar (cm)", padding: 10, cornerRadius: 5, keyboardType: .default, backgroundColor: .init(hexString: "#FAFAFA"), isSecureTextEntry: false)
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.font = UIFont.systemFont(ofSize: 14)
		tf.textColor = .black
		return tf
	}()
	
	lazy var heightTextField: CustomIndentedTextField = {
		let tf :CustomIndentedTextField = CustomIndentedTextField(placeholder: "Tinggi (cm)", padding: 10, cornerRadius: 5, keyboardType: .default, backgroundColor: .init(hexString: "#FAFAFA"), isSecureTextEntry: false)
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.font = UIFont.systemFont(ofSize: 14)
		tf.textColor = .black
		return tf
	}()
	
	let viewFrame = UIView()
	
	// MARK: - Public Method
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		addSubview(viewFrame)
		viewFrame.fillSuperview()
		
		viewFrame.addSubview(nameLabel)
		
		let stackViewDimension = UIStackView(arrangedSubviews: [lengthTextField, heightTextField, widthTextField])
		stackViewDimension.distribution = .fillEqually
		stackViewDimension.translatesAutoresizingMaskIntoConstraints = false
		stackViewDimension.axis = .horizontal
		stackViewDimension.spacing = 5
		
		nameLabel.anchor(top: viewFrame.topAnchor, left: viewFrame.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
		
		viewFrame.addSubview(stackViewDimension)
		
		stackViewDimension.anchor(top: nameLabel.bottomAnchor, left: viewFrame.leftAnchor, bottom: viewFrame.safeAreaLayoutGuide.bottomAnchor, right: viewFrame.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
	}
	
	func textFieldIsEmpty() -> Bool  {
		if lengthTextField.text?.isEmpty ?? false || heightTextField.text?.isEmpty ?? false || heightTextField.text?.isEmpty ?? false {
			return false
		} else {
			return true
		}
	}
}

