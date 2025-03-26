import UIKit

open class KKPasswordTextField: KKBorderedTextField {
    
    private let togglePasswordButton = UIButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isSecureTextEntry = true
        configureToggleShowPasswordButton()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        rightView?.frame = .init(x: bounds.width - bounds.size.height, y: 0, width: bounds.height, height: bounds.height)
    }
}

private extension KKPasswordTextField {
    func configureToggleShowPasswordButton() {
        togglePasswordButton.setImage(.iconEyeOutline, for: .normal)
        togglePasswordButton.imageView?.contentMode = .center
        togglePasswordButton.addTarget(self, action: #selector(toggleShowPassword), for: .touchUpInside)
        
        rightViewMode = .always
        rightView = togglePasswordButton
    }
    
    @objc func toggleShowPassword() {
        isSecureTextEntry.toggle()
        togglePasswordButton.setImage(isSecureTextEntry ? .iconEyeOutline : .iconEyeOffOutline, for: .normal)
    }
}

open class KKPasswordUnderlinedTextField: KKUnderlinedTextField {
    
    private let togglePasswordButton = UIButton()
    private let clearPasswordButton = UIButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isSecureTextEntry = true
        delegate = self
        keyboardType = .asciiCapable
        configureToggleShowPasswordButton()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        rightView?.frame = .init(x: bounds.width - bounds.height, y: 0, width: bounds.height, height: bounds.height)
    }
    
    /// Disable clipboard (copy/paste)
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

private extension KKPasswordUnderlinedTextField {
    func configureToggleShowPasswordButton() {
        clearPasswordButton.setImage(.iconCircleX, for: .normal)
        clearPasswordButton.tintColor = .ashGrey
        clearPasswordButton.imageView?.contentMode = .center
        clearPasswordButton.addTarget(self, action: #selector(clearTextInput), for: .touchUpInside)
        clearPasswordButton.isHidden = true

        togglePasswordButton.setImage(.iconEyeClosed, for: .normal)
        togglePasswordButton.imageView?.contentMode = .center
        togglePasswordButton.addTarget(self, action: #selector(toggleShowPassword), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [clearPasswordButton, togglePasswordButton])
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 8
        
        clearButtonMode = .never
        rightViewMode = .always
        rightView = stack
    }
    
    @objc func toggleShowPassword() {
        isSecureTextEntry.toggle()
        togglePasswordButton.setImage(isSecureTextEntry ? .iconEyeClosed : .iconEyeOpen, for: .normal)
    }
    
    @objc func clearTextInput() {
        text = ""
        clearPasswordButton.isHidden = true
        sendActions(for: .editingChanged)
    }
}

extension KKPasswordUnderlinedTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let text = textField.text, let range = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: range, with: string)
            clearPasswordButton.isHidden = updatedText.isEmpty
        }
        
        /// Disable emoji
        let isContainEmoji = string.unicodeScalars.filter({ $0.properties.isEmoji }).count > 0
        let numberCharacters = string.rangeOfCharacter(from: .decimalDigits)

        if isContainEmoji && numberCharacters == nil {
           return false
        }
        
        return true
    }
}
