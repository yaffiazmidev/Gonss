//
//  CustomTextField.swift
//  Persada
//
//  Created by Muhammad Noor on 03/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import LBTATools

class CustomDimensionTextView: UIView {
    
    // MARK: - Public Property
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: "Dimensi", font: .systemFont(ofSize: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var lengthTextField: IndentedTextField = {
        let tf :IndentedTextField = IndentedTextField(placeholder: "Panjang (cm)", padding: 10, cornerRadius: 5, keyboardType: .default, backgroundColor: .init(hexString: "#FAFAFA"), isSecureTextEntry: false)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        return tf
    }()
    
    lazy var widthTextField: IndentedTextField = {
        let tf :IndentedTextField = IndentedTextField(placeholder: "Lebar (cm)", padding: 10, cornerRadius: 5, keyboardType: .default, backgroundColor: .init(hexString: "#FAFAFA"), isSecureTextEntry: false)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        return tf
    }()
    
    lazy var heightTextField: IndentedTextField = {
        let tf :IndentedTextField = IndentedTextField(placeholder: "Tinggi (cm)", padding: 10, cornerRadius: 5, keyboardType: .default, backgroundColor: .init(hexString: "#FAFAFA"), isSecureTextEntry: false)
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

class CustomTextField: UIView {
    // MARK: - Public Property
    
    var type: UIKeyboardType = .default
    var placeholder: String = ""
    var title: String = ""
    var titleColor: String = ""
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: title, font: .Roboto(.medium, size:12), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .placeholder
        return label
    }()
    
    lazy var nameTextField: IndentedTextField = {
        let tf :IndentedTextField = IndentedTextField(placeholder: placeholder, padding: 15, cornerRadius: 5, keyboardType: type, isSecureTextEntry: false)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.contentVerticalAlignment = .fill
        tf.font = .Roboto(.medium, size:14)
        tf.textColor = .black
        return tf
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
        viewFrame.addSubview(nameTextField)
        
        nameLabel.anchor(top: viewFrame.topAnchor, left: viewFrame.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        nameTextField.anchor(top: nameLabel.bottomAnchor, left: viewFrame.leftAnchor, bottom: viewFrame.safeAreaLayoutGuide.bottomAnchor, right: viewFrame.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        
        
        if !self.titleColor.isEmpty{
            nameLabel.textColor = UIColor(hexString: self.titleColor)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super .draw(rect)
        setupView()
    }
    
    func textFieldIsEmpty() -> Bool  {
        if nameTextField.text?.isEmpty ?? false {
            return false
        } else {
            return true
        }
    }
    
}


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
        
//        rightButton.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
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



class CustomTextView: UIView, UITextViewDelegate {
    
    // MARK: - Public Property
    
    var type: UIKeyboardType = .default
    var placeholder: String = ""
    var title: String = ""
    var titleColor: String = ""
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: title, font: .Roboto(.medium, size:12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var nameTextField: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .left
        textView.delegate = self
        textView.font = .Roboto(.medium, size:14)
        textView.textColor = .black
        if !self.placeholder.isEmpty {
            textView.text = self.placeholder
            textView.textColor = .placeholder
        }
        return textView
    }()
    
    let viewFrame = UIView()
    
    // MARK: - Public Method
    
    
    override func draw(_ rect: CGRect) {
        super .draw(rect)
        
        addSubview(viewFrame)
        viewFrame.translatesAutoresizingMaskIntoConstraints = false
        viewFrame.fillSuperview()
        
        viewFrame.addSubview(nameLabel)
        viewFrame.addSubview(nameTextField)
        
        nameLabel.anchor(top: viewFrame.topAnchor, left: viewFrame.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        nameTextField.anchor(top: nameLabel.bottomAnchor, left: viewFrame.leftAnchor, bottom: viewFrame.safeAreaLayoutGuide.bottomAnchor, right: viewFrame.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        
        if !self.titleColor.isEmpty{
            nameLabel.textColor = UIColor(hexString: self.titleColor)
        }
        
    }
    
    func textFieldIsEmpty() -> Bool  {
        if nameTextField.text?.isEmpty ?? false {
            return false
        } else {
            return true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.placeholder {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.text = placeholder
            textView.textColor = UIColor.placeholder
        }
    }
    
}

