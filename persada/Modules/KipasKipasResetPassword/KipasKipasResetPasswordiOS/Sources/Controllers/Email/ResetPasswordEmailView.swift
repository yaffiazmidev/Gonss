import UIKit
import Combine
import KipasKipasShared
import KipasKipasSharedFoundation

final class ResetPasswordEmailView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingLabel = UILabel()
    private let subheadingLabel = UILabel()
    
    private let emailTextField = KKUnderlinedTextField()
    private let resetButton = KKLoadingButton()
    
    private let errorView = ErrorMessageView()
    
    private var cancellables = Set<AnyCancellable>()
    
    var didTapReset: Closure<String>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        observe()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func observe() {
        let emailValidationPublisher = emailTextField.validationPublisher(
            with: Validators.CombineTwo(
                NonEmptyValidator(errorMessage: "Alamat email harus diisi"),
                BasicEmailValidator(errorMessage: "Masukkan alamat email yang valid")
            )
        )
        
        emailValidationPublisher
            .sink { [weak self] email in
                guard let self = self else { return }
                
                let isValid = email.isValid
                
                emailTextField.text = email.value
                resetButton.isEnabled = isValid
                errorView.setErrorText(email.error?.message)
            }
            .store(in: &cancellables)
        
        resetButton
            .tapPublisher
            .withLatestFrom(emailValidationPublisher)
            .sink { [weak self] email in
                self?.didTapReset?(email.value)
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension ResetPasswordEmailView {
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            resetButton.showLoader([])
        } else {
            resetButton.hideLoader()
        }
    }
    
    func setErrorText(_ text: String) {
        errorView.setErrorText(text)
        resetButton.isEnabled = false
    }
    
    #warning("[BEKA] do we need to handle this error?")
    func showRequestedTooManyOTPError() {
        setErrorText("Anda mengirimkan terlalu banyak kode verifikasi. Segera coba lagi.")
    }
    
    func addEmailExtension(_ emailExtension: String) {
        emailTextField.becomeFirstResponderIfNeeded()
        
        let currentUserTyped = emailTextField.text ?? ""
        let email = currentUserTyped + emailExtension
        
        if let username = email.getUsernameFromEmail(), email.containsEmailExtension() {
            emailTextField.text = username + emailExtension
        } else {
            emailTextField.text = emailExtension
        }
        
        if let text = emailTextField.text {
            emailTextField.setCursorPosition(position: text.count - emailExtension.count)
        }
        
        emailTextField.sendActions(for: .editingChanged)
    }
    
    func setFirstResponder() {
        emailTextField.becomeFirstResponderIfNeeded()
    }
    
    func resignResponder() {
        emailTextField.resignFirstResponder()
    }
}

// MARK: UI
private extension ResetPasswordEmailView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingLabel()
        configureEmailTextField()
        configureErrorView()
        configureResetButton()
    }
    
    func configureContainerView() {
        container.clipsToBounds = true
        
        addSubview(container)
        container.anchors.edges.pin()
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        
        container.addSubview(stackView)
        stackView.anchors.edges.pin()
    }
    
    func configureHeadingLabel() {
        headingLabel.text = "Lupa kata sandi"
        headingLabel.font = .roboto(.bold, size: 18)
        headingLabel.textColor = .night
        
        subheadingLabel.text = "Kami akan mengirimkan email berisi kode untuk mereset kata sandi kamu."
        subheadingLabel.font = .roboto(.regular, size: 14)
        subheadingLabel.textColor = .boulder
        subheadingLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(subheadingLabel)
    }
    
    func configureEmailTextField() {
        emailTextField.lineColor = .boulder
        emailTextField.lineWidth = 0.5
        emailTextField.activeLineColor = .watermelon
        emailTextField.activeLineWidth = 0.5
        emailTextField.font = .roboto(.medium, size: 16)
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .asciiCapable
        emailTextField.clearButtonMode = .whileEditing
        emailTextField.textColor = .gravel
        
        emailTextField.placeholderText = "Alamat email"
        emailTextField.placeholderColor = .ashGrey
        emailTextField.placeholderLabel.font = .roboto(.regular, size: 16)
        
        stackView.addArrangedSubview(spacer(32))
        stackView.addArrangedSubview(emailTextField)
        emailTextField.anchors.height.equal(40)
    }
    
    func configureResetButton() {
        resetButton.indicator = MaterialLoadingIndicatorSimple(radius: 10.0)
        resetButton.indicatorPosition = .right
        resetButton.setBackgroundColor(.watermelon, for: .normal)
        resetButton.setBackgroundColor(.snowDrift, for: .disabled)
        resetButton.indicator.color = .white
        resetButton.isEnabled = false
        resetButton.titleLabel?.font = .roboto(.bold, size: 16)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.setTitleColor(.ashGrey, for: .disabled)
        resetButton.layer.cornerRadius = 4
        resetButton.clipsToBounds = true
        
        stackView.addArrangedSubview(spacer(32))
        stackView.addArrangedSubview(resetButton)
        
        resetButton.anchors.height.equal(40)
    }
    
    func configureErrorView() {
        errorView.isHidden = true
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(errorView)
    }
}
