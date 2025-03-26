import UIKit
import Combine
import KipasKipasShared

final class LoginPasswordView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingLabel = UILabel()
    
    private let passwordTextField = KKPasswordUnderlinedTextField()
    private let forgotPasswordButton = KKBaseButton()
    private let loginButton = KKLoadingButton()
    
    private let errorView = ErrorMessageView()
    
    private var cancellables = Set<AnyCancellable>()
    
    var didTapLogin: Closure<String>?
    var didTapForgotPassword: (() -> Void)?
    
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
        let passwordPublisher = passwordTextField.validationPublisher(
            with: Validators.CombineTwo(
                NonEmptyValidator(errorMessage: "Harap masukkan kata sandi"),
                MinimumLengthValidator(min: 8, errorMessage: "")
            )
        )
        
        passwordPublisher
            .sink { [weak self] phone in
                guard let self = self else { return }
                
                let isValid = phone.isValid
                
                passwordTextField.text = phone.value
                loginButton.isEnabled = isValid
                errorView.setErrorText(phone.error?.message)
            }
            .store(in: &cancellables)
        
        loginButton
            .tapPublisher
            .withLatestFrom(passwordPublisher)
            .sink { [weak self] password in
                self?.didTapLogin?(password.value)
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension LoginPasswordView {
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            loginButton.showLoader([])
        } else {
            loginButton.hideLoader()
        }
    }
    
    func setErrorText(_ text: String) {
        errorView.setErrorText(text)
        loginButton.isEnabled = false
    }
    
    func setFirstResponder() {
        passwordTextField.becomeFirstResponder()
    }
    
    func resignResponder() {
        passwordTextField.resignFirstResponder()
    }
}

// MARK: UI
private extension LoginPasswordView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingLabel()
        configurePhoneTextField()
        configureErrorView()
        configureForgotPasswordButton()
        configureLoginButton()
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
        headingLabel.text = "Masukkan kata sandi"
        headingLabel.font = .roboto(.bold, size: 20)
        headingLabel.textColor = .night
        
        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(spacer(48))
    }
    
    func configurePhoneTextField() {
        passwordTextField.lineColor = .boulder
        passwordTextField.lineWidth = 0.5
        passwordTextField.activeLineColor = .watermelon
        passwordTextField.activeLineWidth = 0.5
        passwordTextField.font = .roboto(.medium, size: 16)
        passwordTextField.autocapitalizationType = .none
        passwordTextField.keyboardType = .asciiCapable
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.textColor = .gravel
        
        passwordTextField.placeholderText = "Kata sandi"
        passwordTextField.placeholderColor = .ashGrey
        passwordTextField.placeholderLabel.font = .roboto(.regular, size: 16)
        
        stackView.addArrangedSubview(passwordTextField)
        passwordTextField.anchors.height.equal(40)
    }
    
    func configureErrorView() {
        errorView.isHidden = true
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(errorView)
    }
    
    func configureForgotPasswordButton() {
        forgotPasswordButton.titleLabel?.font = .roboto(.medium, size: 14)
        forgotPasswordButton.setTitle("Lupa kata sandi?", for: .normal)
        forgotPasswordButton.setTitleColor(.night, for: .normal)
        forgotPasswordButton.contentHorizontalAlignment = .leading
        
        forgotPasswordButton.tapPublisher
            .sink { [weak self] _ in self?.didTapForgotPassword?() }
            .store(in: &cancellables)
        
        stackView.addArrangedSubview(spacer(8))
        stackView.addArrangedSubview(forgotPasswordButton)
    }
    
    func configureLoginButton() {
        loginButton.indicator = MaterialLoadingIndicatorSimple(radius: 10.0)
        loginButton.indicatorPosition = .right
        loginButton.setBackgroundColor(.watermelon, for: .normal)
        loginButton.setBackgroundColor(.snowDrift, for: .disabled)
        loginButton.indicator.color = .white
        loginButton.isEnabled = false
        loginButton.titleLabel?.font = .roboto(.bold, size: 16)
        loginButton.setTitle("Masuk", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(.ashGrey, for: .disabled)
        loginButton.layer.cornerRadius = 4
        loginButton.clipsToBounds = true
        
        stackView.addArrangedSubview(spacer(20))
        stackView.addArrangedSubview(loginButton)
        
        loginButton.anchors.height.equal(40)
    }
}
