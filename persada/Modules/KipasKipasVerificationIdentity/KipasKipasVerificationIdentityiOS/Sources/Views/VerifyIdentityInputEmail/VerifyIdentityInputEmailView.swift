import UIKit
import KipasKipasShared

class VerifyIdentityInputEmailView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeContainerStack: UIStackView!
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()
    
    var isEnableSaveButton: Bool = false {
        didSet {
            saveButton.isEnabled = isEnableSaveButton
            saveButton.setTitleColor(isEnableSaveButton ? .white : .placeholder, for: .normal)
            saveButton.backgroundColor = isEnableSaveButton ? .gradientStoryOne : UIColor(hexString: "#F9F9F9")
        }
    }
    
    var didSaveEmail: ((String) -> Void)?
    
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
    
    func setupComponent() {
        overrideUserInterfaceStyle = .light
        errorLabel.isHidden = true
        saveButton.isEnabled = false
        emailTextField.keyboardType = .emailAddress
        emailTextField.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        emailTextField.isUserInteractionEnabled = true
    }

    @IBAction func didClickSaveButton(_ sender: Any) {
        guard let text = emailTextField.text else { return }
        didSaveEmail?(text)
    }
    
    @objc private func textFieldValueChange(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            errorLabel.isHidden = true
            isEnableSaveButton = false
            return
        }
        
        guard text.isValidEmail() else {
            errorLabel.isHidden = false
            errorLabel.text = "Masukkan alamat email yang valid"
            isEnableSaveButton = false
            return
        }
        
        guard text != verifyIdentityStored.retrieve()?.userEmail ?? "" else {
            errorLabel.isHidden = false
            errorLabel.text = "Masukkan alamat email yang berbeda"
            isEnableSaveButton = false
            return
        }
        
        isEnableSaveButton = true
        errorLabel.isHidden = true
    }
}

extension String {
    
    func isValidEmail() -> Bool {
        return applyPredicateOnRegex(regexStr: "[A-Z0-9a-z._%+-]{1,64}@[A-Za-z0-9.-]{2,64}\\.[A-Za-z]{2,64}")
    }
    
    func applyPredicateOnRegex(regexStr: String) -> Bool{
        let trimmedString = self.trimmingCharacters(in: .whitespaces)
        let validateOtherString = NSPredicate(format: "SELF MATCHES %@", regexStr)
        let isValidateOtherString = validateOtherString.evaluate(with: trimmedString)
        return isValidateOtherString
    }
}
