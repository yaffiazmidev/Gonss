//
//  CustomTextField.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class CustomTextField: UIView {
	
	// MARK: - Public Property
    var handleTextFieldEditingChanged: ((UITextField) -> Void)?
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
		label.textColor = .grey
		return label
	}()
	
	lazy var nameTextField: CustomIndentedTextField = {
        let tf :CustomIndentedTextField = CustomIndentedTextField(placeholder: placeholder, paddingX: 12, paddingY: 14, cornerRadius: 5, keyboardType: type, isSecureTextEntry: false, borderWidth: 1, borderColor: .gainsboro)
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.contentVerticalAlignment = .fill
		tf.font = .Roboto(.regular, size:14)
		tf.textColor = .black
		tf.tintColor = .black
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
		return tf
	}()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel(font: .Roboto(.medium ,size: 12), textColor: .warning, textAlignment: .left, numberOfLines: 2)
        return label
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
        
        let fieldStackView = UIStackView(arrangedSubviews: [nameLabel, nameTextField])
        fieldStackView.axis = .vertical
        fieldStackView.spacing = 6
        let stackView = UIStackView(arrangedSubviews: [fieldStackView, errorLabel])
        viewFrame.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 6
		
        
        stackView.anchor(top: viewFrame.topAnchor, left: viewFrame.leftAnchor, bottom: viewFrame.safeAreaLayoutGuide.bottomAnchor, right: viewFrame.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
		
		if !self.titleColor.isEmpty{
			nameLabel.textColor = UIColor(hexString: self.titleColor)
		}
        
        nameTextField.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(textFieldEndEditing(_:)), for: .editingDidEnd)
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
    
    @objc private func textFieldValueChange(_ textField: UITextField) {
        handleTextFieldEditingChanged?(textField)
    }
    
    @objc private func textFieldEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func showError(_ text: String?){
        let shouldHideError = text == nil || text?.isEmpty == true
        errorLabel.isHidden = shouldHideError
        errorLabel.text = text
        nameTextField.layer.borderColor = shouldHideError ? UIColor.gainsboro.cgColor : UIColor.warning.cgColor
    }
    
    func hideError() {
        errorLabel.isHidden = true
        errorLabel.text = ""
        nameTextField.layer.borderColor = UIColor.gainsboro.cgColor
    }
}



