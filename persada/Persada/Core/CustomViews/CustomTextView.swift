//
//  CustomTextView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

protocol CustomTextViewDelegate{
    func textViewDidChange(_ textView: UITextView)
}

class CustomTextView: UIView, UITextViewDelegate {

    // MARK: - Public Property

    var type: UIKeyboardType = .default
    
    var placeholder: String = "" {
           didSet{
               self.nameTextField.text = placeholder
               self.nameTextField.textColor = .placeholder
           }
       }
    
    var placeholderFloating: String = "" {
        didSet{
            placeholderLabel.text = placeholderFloating
            placeholderLabel.sizeToFit()
            nameTextField.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 15, y: (nameTextField.font?.pointSize)! / 2 + 10)
            placeholderLabel.isHidden = !nameTextField.text.isEmpty
        }
    }
    
    var title: String = "" {
        didSet {
            self.nameLabel.text = title
        }
    }
    var titleColor: String = ""
    var maxLength: Int = 1000
    var ctvDelegate: CustomTextViewDelegate?
    var handleTextFieldEditingChanged: ((UITextView) -> Void)?

    lazy var nameLabel: UILabel = {
        let label = UILabel(text: title, font: .Roboto(.medium, size:12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var placeholderLabel : UILabel = {
        let label = UILabel()
        label.font = .Roboto(.medium, size:12)
        label.sizeToFit()
        label.textColor = .placeholder
        return label
    }()

    lazy var nameTextField: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .left
        textView.delegate = self
        textView.font = .Roboto(.regular, size:14)
        textView.textColor = .black
        textView.backgroundColor = .white
        if !self.placeholder.isEmpty {
            textView.text = self.placeholder
            textView.textColor = .placeholder
        }
        return textView
    }()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel(font: .Roboto(.medium ,size: 12), textColor: .warning, textAlignment: .left, numberOfLines: 2)
        return label
    }()

    let viewFrame = UIView(frame: .zero)

    // MARK: - Public Method

    override init(frame: CGRect) {
        super.init(frame: frame)
        draw(.zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func draw(_ rect: CGRect) {
        super .draw(rect)

        addSubview(viewFrame)
        viewFrame.translatesAutoresizingMaskIntoConstraints = false
        viewFrame.fillSuperview()

        viewFrame.addSubview(nameLabel)
        viewFrame.addSubview(nameTextField)
        
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

    }
    
    func showError(_ text: String){
        errorLabel.isHidden = false
        errorLabel.text = text
        nameTextField.layer.borderColor = UIColor.warning.cgColor
    }
    
    func hideError() {
        errorLabel.isHidden = true
        errorLabel.text = ""
        nameTextField.layer.borderColor = UIColor.gainsboro.cgColor
    }

    func textFieldIsEmpty() -> Bool  {
        if nameTextField.text?.isEmpty ?? false {
            return false
        } else {
            return true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        ctvDelegate?.textViewDidChange(textView)
        handleTextFieldEditingChanged?(textView)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if !placeholder.isEmpty {
            if textView.textColor == UIColor.placeholder {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        }
        
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if !placeholder.isEmpty {
            if textView.text.isEmpty{
                textView.text = placeholder
                textView.textColor = UIColor.placeholder
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxLength
    }
}

