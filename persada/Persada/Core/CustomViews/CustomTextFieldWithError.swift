//
//  CustomTextFieldWithError.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 17/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

class CustomTextFieldWithError : UIView {
		
		var type: UIKeyboardType = .default
		var placeholder: String = ""
		var title: String = ""
		var titleColor: String = ""
		var isActive : Bool?
		
		
		lazy var nameLabel: UILabel = {
				let label = UILabel(text: title, font: .Roboto(.medium, size:12), textColor: .black, textAlignment: .left, numberOfLines: 0)
				label.translatesAutoresizingMaskIntoConstraints = false
				label.textColor = .placeholder
				return label
		}()
		
		lazy var textField: CustomIndentedTextFieldWithButton = {
				let tf  = CustomIndentedTextFieldWithButton()
				tf.translatesAutoresizingMaskIntoConstraints = false
				tf.contentVerticalAlignment = .fill
				tf.font = .Roboto(.medium, size:14)
				tf.textColor = .contentGrey
				return tf
		}()
		
		lazy var rightButton: UIButton = {
				let button = UIButton()
				button.contentEdgeInsets = UIEdgeInsets(top: 15,left: 15,bottom: 15,right: 15)
				button.translatesAutoresizingMaskIntoConstraints = false
				button.setTitleColor(.systemBlue, for: .normal)
				button.setTitleColor(.placeholder, for: .disabled)
				button.titleLabel?.font = .Roboto(.medium, size:14)
				return button
		}()
		
		lazy var errorLabel: UILabel = {
				let label = UILabel(text: "", font: .Roboto(.medium, size:12), textColor: .redError, textAlignment: .left, numberOfLines: 0)
				label.translatesAutoresizingMaskIntoConstraints = false
				return label
		}()
		
		
		let viewFrame = UIView()
		
		// MARK: - Public Method
		
		override init(frame: CGRect) {
				super.init(frame: frame)
				setupView()
		}
		
		required init?(coder: NSCoder) {
				fatalError("init(coder:) has not been implemented")
		}
		
		
		fileprivate func setupView() {
				addSubview(viewFrame)
				viewFrame.translatesAutoresizingMaskIntoConstraints = false
				viewFrame.fillSuperview()
				
				viewFrame.addSubview(nameLabel)
				viewFrame.addSubview(textField)
				viewFrame.addSubview(rightButton)
				viewFrame.addSubview(errorLabel)
				
				
				nameLabel.anchor(top: viewFrame.topAnchor, left: viewFrame.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
				
				
				textField.anchor(top: nameLabel.bottomAnchor, left: viewFrame.leftAnchor, bottom: viewFrame.safeAreaLayoutGuide.bottomAnchor, right: viewFrame.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
				
				textField.rightViewMode = UITextField.ViewMode.always
				textField.rightView = rightButton
				
				errorLabel.anchor(top: textField.bottomAnchor, left: viewFrame.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 5, paddingRight: 10, width: 10)
				
				if !self.titleColor.isEmpty{
						nameLabel.textColor = UIColor(hexString: self.titleColor)
				}
				
		}
		
		override func draw(_ rect: CGRect) {
				super .draw(rect)
				setupView()
		}
		
		func textFieldIsEmpty() -> Bool  {
				if textField.text?.isEmpty ?? false {
						return false
				} else {
						return true
				}
		}
		
		func showErrorLabel(message: String, buttonTitle: String) {
				errorLabel.isHidden = false
				errorLabel.text = message
				textField.layer.borderWidth = 1
				textField.layer.borderColor = UIColor.red.cgColor
				textField.layer.backgroundColor = UIColor.white.cgColor
				rightButton.isEnabled = false
				rightButton.setTitle(buttonTitle, for: .normal)
				isActive = false
		}
		
		func hideErrorLabel(buttonTitle : String){
				setActive(buttonTitle: buttonTitle)
		}
		
		func setActive(buttonTitle : String) {
				errorLabel.isHidden = true
				textField.layer.borderWidth = 1
				textField.layer.backgroundColor = UIColor.white.cgColor
				textField.layer.borderColor = UIColor.secondaryLowTint.cgColor
				rightButton.isEnabled = true
				rightButton.setTitle(buttonTitle, for: .normal)
				textField.isUserInteractionEnabled = true
				textField.becomeFirstResponder()
				isActive = true
		}
		
		func setInActive(){
				errorLabel.isHidden = true
				rightButton.isEnabled = false
				rightButton.isHidden = false
				textField.layer.borderColor = UIColor.whiteSmoke.cgColor
				textField.layer.borderWidth = 0
				textField.layer.backgroundColor = UIColor.whiteSmoke.cgColor
				textField.isUserInteractionEnabled = false
				textField.resignFirstResponder()
				isActive = false
				print("INACTIve")
		}
		
    func setInActiveDisappear(){
            errorLabel.isHidden = true
            rightButton.isEnabled = false
            rightButton.isHidden = true
            textField.layer.borderColor = UIColor.whiteSmoke.cgColor
            textField.layer.borderWidth = 0
            textField.layer.backgroundColor = UIColor.whiteSmoke.cgColor
            textField.isUserInteractionEnabled = false
            textField.resignFirstResponder()
            isActive = false
            print("INACTIve")
    }
		func enableTextField(){
				textField.isUserInteractionEnabled = true
		}
		
		func disableTextField(){
				textField.isUserInteractionEnabled = false
		}
		
}
