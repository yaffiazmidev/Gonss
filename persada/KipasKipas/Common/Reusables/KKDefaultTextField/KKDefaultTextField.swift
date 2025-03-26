//
//  KKDefaultTextField.swift
//  KipasKipas
//
//  Created by DENAZMI on 20/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class KKDefaultTextField: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var rightIconImageView: UIImageView!
    @IBOutlet weak var textFieldContainerStackView: UIStackView!
    @IBOutlet weak var textFiledHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockingView: UIView!
    
    
    var isBlockingView: Bool = false {
        didSet {
            blockingView.isUserInteractionEnabled = isBlockingView
            blockingView.isHidden = !isBlockingView
        }
    }
    
    var leftIcon: UIImage? = nil {
        didSet {
            leftIconImageView.image = leftIcon
            leftIconImageView.isHidden = leftIcon == nil
        }
    }
    
    var rightIcon: UIImage? = nil {
        didSet {
            rightIconImageView.image = rightIcon
            rightIconImageView.isHidden = rightIcon == nil
        }
    }
    
    var title: String? = nil {
        didSet {
            titleLabel.text = title
            titleLabel.isHidden = title == nil || title == ""
        }
    }
    
    var placeholder: String? = nil {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            textFieldContainerStackView.layer.cornerRadius = cornerRadius
        }
    }
    
    var borderWidth: CGFloat = 0 {
        didSet {
            textFieldContainerStackView.layer.borderWidth = borderWidth
        }
    }

    var borderColor: UIColor? = .clear {
        didSet {
            textFieldContainerStackView.layer.borderColor = borderColor?.cgColor
        }
    }
    
    private var isError: Bool = false
    var isAllowWhitespaces: Bool = true
    var selectedBorderColor: UIColor? = .link
    var errorBorderColor: UIColor? = .red
    var errorMessageColor: UIColor? = .red
    
    var handleTapLeftIcon: (() -> Void)?
    var handleTapRightIcon: (() -> Void)?
    var handleTapBlockingView: (() -> Void)?
    var handleTextFieldShouldClear: ((UITextField) -> Void)?
    var handleTextFieldShouldReturn: ((UITextField) -> Void)?
    var handleTextFieldDidEndEditing: ((UITextField) -> Void)?
    var handleTextFieldEditingChanged: ((UITextField) -> Void)?
    var handleTextFieldDidBeginEditing: ((UITextField) -> Void)?
    var handleTextFieldShouldEndEditing: ((UITextField) -> Void)?
    var handleTextFieldShouldBeginEditing: ((UITextField) -> Void)?
    var handleTextFieldDidChangeSelection: ((UITextField) -> Void)?
    var handleTextFieldDidEndEditingReason: ((UITextField, UITextField.DidEndEditingReason) -> Void)?
    var handleTextField: ((UITextField, NSRange, String) -> Void)?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        setupComponent()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        setupComponent()
    }
    
    func set(title: String = "",
             titleTextColor: UIColor = .black,
             placeholder: String = "",
             leftIcon: UIImage? = nil,
             rightIcon: UIImage? = nil,
             isSecureTextEntry: Bool = false) {
        
        titleLabel.text = title
        titleLabel.textColor = titleTextColor
        titleLabel.isHidden = title.isEmpty
        
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecureTextEntry
        
        leftIconImageView.image = leftIcon
        leftIconImageView.isHidden = leftIcon == nil
        
        rightIconImageView.image = rightIcon
        rightIconImageView.isHidden = rightIcon == nil
        
        
    }
    
    func setBorder(width: CGFloat, color: UIColor) {
        borderWidth = width
        borderColor = color
    }
}

extension KKDefaultTextField {
    private func setupComponent() {
        handleOnTapItems()
        setBorder(width: 1, color: .lightGray)
        cornerRadius = 8
        
        textField.delegate = self
        errorMessageLabel.textColor = errorMessageColor
        textField.attributedPlaceholder = NSAttributedString(
            string: self.placeholder ?? "Type something..",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        textField.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        textField.isUserInteractionEnabled = true
    }
    
    private func handleOnTapItems() {
        let onTapGestureLeftIcon = UITapGestureRecognizer(target: self, action: #selector(didTapLeftIcon))
        leftIconImageView.addGestureRecognizer(onTapGestureLeftIcon)
        
        let onTapGestureRightIcon = UITapGestureRecognizer(target: self, action: #selector(didTapRightIcon))
        rightIconImageView.addGestureRecognizer(onTapGestureRightIcon)
        
        let onTapGestureBlockingView = UITapGestureRecognizer(target: self, action: #selector(didTapBlockingView))
        blockingView.addGestureRecognizer(onTapGestureBlockingView)
    }
    
    @objc private func didTapLeftIcon() {
        handleTapLeftIcon?()
    }
    
    @objc private func didTapRightIcon() {
        handleTapRightIcon?()
    }
    
    @objc private func didTapBlockingView() {
        handleTapBlockingView?()
    }
    
    @objc private func textFieldValueChange(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            isError = false
            hideError()
            borderColor = selectedBorderColor
        }
        
        handleTextFieldEditingChanged?(textField)
    }
    
    func showError(_ message: String) {
        isError = true
        borderColor = errorBorderColor
        errorMessageLabel.text = message
        errorMessageLabel.isHidden = false
    }
    
    func hideError() {
        isError = false
        borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        errorMessageLabel.text = nil
        errorMessageLabel.isHidden = true
    }
}

extension KKDefaultTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        handleTextFieldShouldBeginEditing?(textField)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !isError {
            borderColor = selectedBorderColor
            errorMessageLabel.isHidden = true
        }
        
        handleTextFieldDidBeginEditing?(textField)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !isError {
            borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        }
        
        handleTextFieldShouldEndEditing?(textField)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        handleTextFieldDidEndEditing?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        handleTextFieldDidEndEditingReason?(textField, reason)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !isAllowWhitespaces {
            let invalidCharacterSet = NSCharacterSet.whitespaces
            let range = string.rangeOfCharacter(from: invalidCharacterSet)
            
            // If the replacement string contains whitespace, don't allow the change
            if let _ = range {
                return false
            }
        }
        
        handleTextField?(textField, range, string)
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        handleTextFieldDidChangeSelection?(textField)
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        handleTextFieldShouldClear?(textField)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        handleTextFieldShouldReturn?(textField)
        return true
    }
}
