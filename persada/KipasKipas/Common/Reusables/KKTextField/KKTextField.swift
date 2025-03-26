//
//  KKTextField.swift
//  KipasKipas
//
//  Created by DENAZMI on 11/10/22.
//

import UIKit

class KKTextField: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var rightIconImageView: UIImageView!
    @IBOutlet weak var textFieldContainerStackView: UIStackView!
    @IBOutlet weak var textFiledHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockingView: UIView!
    
    
    @IBInspectable var clickingMode: Bool = false {
        didSet {
            blockingView.isUserInteractionEnabled = clickingMode
            blockingView.isHidden = !clickingMode
        }
    }
    
    @IBInspectable var leftIcon: UIImage? = nil {
        didSet {
            leftIconImageView.image = leftIcon
            leftIconImageView.isHidden = leftIcon == nil
        }
    }
    
    @IBInspectable var rightIcon: UIImage? = nil {
        didSet {
            rightIconImageView.image = rightIcon
            rightIconImageView.isHidden = rightIcon == nil
        }
    }
    
    @IBInspectable var title: String? = nil {
        didSet {
            titleLabel.text = title
            titleLabel.isHidden = title == nil
        }
    }
    
    @IBInspectable var placeholder: String? = nil {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return textFieldContainerStackView.layer.cornerRadius }
        set { textFieldContainerStackView.layer.cornerRadius = newValue }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return textFieldContainerStackView.layer.borderWidth }
        set { textFieldContainerStackView.layer.borderWidth = newValue }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = textFieldContainerStackView.layer.borderColor { return UIColor(cgColor: color) }
            return nil
        } set { textFieldContainerStackView.layer.borderColor = newValue?.cgColor }
    }
    
    @IBInspectable var secureTextEntry: Bool = false {
        didSet {
            textField.isSecureTextEntry = secureTextEntry
        }
    }
    
    @IBInspectable var selectedBorderColor: UIColor?
    @IBInspectable var errorBorderColor: UIColor? = .red
    @IBInspectable var errorMessageColor: UIColor? = .red
    
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
}

extension KKTextField {
    private func setupComponent() {
        handleOnTapItems()
        setupDefaultFieldBorder()
        
        textField.delegate = self
        errorMessageLabel.textColor = errorMessageColor
        textField.attributedPlaceholder = NSAttributedString(
            string: self.placeholder ?? "Type something..",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        textField.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        textField.isUserInteractionEnabled = true
    }
    
    private func setupDefaultFieldBorder() {
        borderColor = .lightGray
        borderWidth = 1
        cornerRadius = 8
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
        handleTextFieldEditingChanged?(textField)
    }
    
    func showError(_ message: String) {
        borderColor = errorBorderColor
        errorMessageLabel.text = message
        errorMessageLabel.isHidden = false
    }
    
    func hideError() {
        borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        errorMessageLabel.text = nil
        errorMessageLabel.isHidden = true
    }
}

extension KKTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        handleTextFieldShouldBeginEditing?(textField)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        borderColor = selectedBorderColor
        errorMessageLabel.isHidden = true
        handleTextFieldDidBeginEditing?(textField)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
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


extension UIView {

    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            return nil
        }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
        return contentView
    }
}
