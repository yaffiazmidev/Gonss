import UIKit
import KipasKipasShared

class VerifyIdentityInputPhoneNumberView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeContainerStack: UIStackView!
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()
    
    var didSavePhoneNumber: ((String) -> Void)?
    
    var isEnableSaveButton: Bool = false {
        didSet {
            saveButton.isEnabled = isEnableSaveButton
            saveButton.setTitleColor(isEnableSaveButton ? .white : .placeholder, for: .normal)
            saveButton.backgroundColor = isEnableSaveButton ? .gradientStoryOne : UIColor(hexString: "#F9F9F9")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    @IBAction func didClickSaveButton(_ sender: Any) {
        guard let text = phoneNumberTextField.text else { return }
        didSavePhoneNumber?(text)
    }
    
    func setupComponent() {
        overrideUserInterfaceStyle = .light
        errorLabel.isHidden = true
        saveButton.isEnabled = false
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        phoneNumberTextField.isUserInteractionEnabled = true
    }
    
    @objc private func textFieldValueChange(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            errorLabel.isHidden = true
            isEnableSaveButton = false
            return
        }
        
        guard text.isValidPhoneNumber() else {
            errorLabel.isHidden = false
            errorLabel.text = "Masukkan nomor telepon yang valid"
            isEnableSaveButton = false
            return
        }
        
        guard text != verifyIdentityStored.retrieve()?.userMobile ?? "" else {
            errorLabel.isHidden = false
            errorLabel.text = "Masukkan nomor telepon yang berbeda"
            isEnableSaveButton = false
            return
        }
        
        isEnableSaveButton = true
        errorLabel.isHidden = true
    }
}


extension String {
    
    func isValidPhoneNumber() -> Bool {
        return isValid(with: "^(628[0-9]{7,15}|08[0-9]{7,14})$")
    }
    
    func isValid(with regex: String) -> Bool {
        let pattern = regex
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }
}
