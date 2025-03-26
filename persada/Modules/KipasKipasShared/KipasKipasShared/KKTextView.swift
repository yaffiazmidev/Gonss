import UIKit

public protocol KKTextViewDelegate: AnyObject {
    func textViewDidBeginEditing(_ textView: UITextView)
    func textViewDidChange(_ textView: UITextView)
}

public class KKTextView: UIView, UITextViewDelegate {
    
    public var type: UIKeyboardType = .default
    
    public var placeholder: String = "" {
        didSet{
            self.nameTextField.text = placeholder
            self.nameTextField.textColor = .ashGrey
        }
    }
    
    public var placeholderFloating: String = "" {
        didSet{
            placeholderLabel.text = placeholderFloating
            placeholderLabel.sizeToFit()
            nameTextField.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 15, y: (nameTextField.font?.pointSize)! / 2 + 10)
            placeholderLabel.isHidden = !nameTextField.text.isEmpty
        }
    }
    
    public var title: String = "" {
        didSet {
            self.nameLabel.text = title
        }
    }
    
    public var maxLength: Int = 1000
    public var ctvDelegate: KKTextViewDelegate?
    public var handleTextFieldEditingChanged: ((UITextView) -> Void)?
    
    private(set) public lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.font = .roboto(.medium, size: 12)
        label.textColor = .boulder
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderLabel : UILabel = {
        let label = UILabel()
        label.font = .roboto(.medium, size: 12)
        label.sizeToFit()
        label.textColor = .ashGrey
        return label
    }()
    
    private(set) public lazy var nameTextField: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .left
        textView.delegate = self
        textView.font = .roboto(.regular, size: 14)
        textView.textColor = .black
        textView.backgroundColor = .white
        if !self.placeholder.isEmpty {
            textView.text = self.placeholder
            textView.textColor = .ashGrey
        }
        return textView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .roboto(.medium, size: 12)
        label.textColor = .brightRed
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let viewFrame = UIView(frame: .zero)
  
    public override init(frame: CGRect) {
        super.init(frame: frame)
        draw(.zero)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func draw(_ rect: CGRect) {
        super .draw(rect)
        addSubview(viewFrame)
        viewFrame.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewFrame.topAnchor.constraint(equalTo: topAnchor),
            viewFrame.leadingAnchor.constraint(equalTo: leadingAnchor),
            viewFrame.bottomAnchor.constraint(equalTo: bottomAnchor),
            viewFrame.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        viewFrame.addSubview(nameLabel)
        viewFrame.addSubview(nameTextField)
        
        let fieldStackView = UIStackView(arrangedSubviews: [nameLabel, nameTextField])
        fieldStackView.axis = .vertical
        fieldStackView.spacing = 6
        
        let stackView = UIStackView(arrangedSubviews: [fieldStackView, errorLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 6
        
        viewFrame.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: viewFrame.topAnchor, constant: 2),
            stackView.leadingAnchor.constraint(equalTo: viewFrame.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: viewFrame.safeAreaLayoutGuide.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: viewFrame.trailingAnchor)
        ])
    }
    
    func showError(_ text: String){
        errorLabel.isHidden = false
        errorLabel.text = text
        nameTextField.layer.borderColor = UIColor.brightRed.cgColor
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
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        ctvDelegate?.textViewDidChange(textView)
        handleTextFieldEditingChanged?(textView)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if !placeholder.isEmpty {
            textView.text = nil
        }
        ctvDelegate?.textViewDidBeginEditing(textView)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if !placeholder.isEmpty {
            if textView.text.isEmpty{
                textView.text = placeholder
                textView.textColor = UIColor.ashGrey
            }
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxLength
    }
}
