import UIKit
import Combine
import KipasKipasShared

final class LoginView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    private let usernameContainerStackView = UIStackView()
    private let passwordContainerStackView = UIStackView()
    
    private let headingLabel = UILabel()
    private let subheadingLabel = UILabel()
    private let headingStackView = UIStackView()
    
    private let usernameTextField = KKUnderlinedTextField()
    private let passwordTextField = KKPasswordUnderlinedTextField()
    
    private let forgotPasswordButton = KKBaseButton()
    private let loginButton = KKLoadingButton()
    private let errorView = ErrorMessageView()
    
    private var cancellables = Set<AnyCancellable>()
    
    var loginButtonCallback: ((_ username: String, _ password: String) -> Void)?
    var forgotPasswordButtonCallback: (() -> Void)?
    
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
        let usernamePublisher = usernameTextField.validationPublisher(
            with: NonEmptyValidator(errorMessage: "Harap masukkan alamat email atau nama pengguna")
        )
        
        let passwordPublisher = passwordTextField.validationPublisher(
            with: Validators.CombineTwo(
                NonEmptyValidator(errorMessage: "Harap masukkan kata sandi"),
                MinimumLengthValidator(min: 8, errorMessage: "")
            )
        )
        /// Remove spaces input
        usernamePublisher
            .sink { [weak self] result in
                self?.usernameTextField.text = result.value.trimmingCharacters(in: .whitespaces)
            }
            .store(in: &cancellables)
        
        passwordPublisher
            .sink { [weak self] result in
                self?.passwordTextField.text = result.value.trimmingCharacters(in: .whitespaces)
            }
            .store(in: &cancellables)
        
        usernamePublisher
            .combineLatest(passwordPublisher)
            .sink(receiveValue: { [weak self] username, password in
                guard let self = self else { return }
                
                let isAllValid = username.isValid && password.isValid
                
                self.usernameTextField.isError = !username.isValid
                self.passwordTextField.isError = !password.isValid
                self.errorView.isHidden = isAllValid
                self.loginButton.isEnabled = isAllValid
                
                switch (username.isValid, password.isValid) {
                case (true, true): break
                case (true, false):
                    self.errorView.setErrorText(password.error?.message)
                case (false, true):
                    self.errorView.setErrorText(username.error?.message)
                case (false, false):
                    self.errorView.isHidden = true
                    self.loginButton.isEnabled = false
                }
            })
            .store(in: &cancellables)
        
        loginButton.tapPublisher
            .withLatestFrom(usernamePublisher.combineLatest(passwordPublisher))
            .sink { [weak self] username, password in
                guard let self = self else { return }
                loginButtonCallback?(username.value, password.value)
            }
            .store(in: &cancellables)
    }
}

// MARK: UI
private extension LoginView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingLabel()
        configureUsernameContainerStackView()
        configurePasswordContainerStackView()
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
        stackView.anchors.top.pin(inset: 40)
        stackView.anchors.edges.pin(insets: 24, axis: .horizontal)
        stackView.anchors.bottom.pin(inset: 24)
    }
    
    func configureHeadingLabel() {
        headingStackView.axis = .vertical
        headingStackView.spacing = 12
        
        headingLabel.text = "Anda sudah terdaftar"
        headingLabel.font = .roboto(.bold, size: 18)
        headingLabel.textColor = .night
        
        subheadingLabel.text = "Masukan kata sandi Anda untuk masuk ke aplikasi."
        subheadingLabel.font = .roboto(.regular, size: 14)
        subheadingLabel.textColor = .boulder
        subheadingLabel.numberOfLines = 0
        
        headingStackView.addArrangedSubview(headingLabel)
        headingStackView.addArrangedSubview(subheadingLabel)
        headingStackView.addArrangedSubview(spacer(36))
        
        stackView.addArrangedSubview(headingStackView)
    }
    
    func configureUsernameContainerStackView() {
        usernameContainerStackView.axis = .vertical
        usernameContainerStackView.spacing = 12
        
        configureUsernameTextField()
        stackView.addArrangedSubview(usernameContainerStackView)
    }
    
    func configurePasswordContainerStackView() {
        passwordContainerStackView.axis = .vertical
        passwordContainerStackView.spacing = 12
        
        configurePasswordTextField()
        configureErrorLabel()
        
        stackView.addArrangedSubview(spacer(32))
        stackView.addArrangedSubview(passwordContainerStackView)
    }
    
    func configureUsernameTextField() {
        usernameTextField.lineColor = .boulder
        usernameTextField.lineWidth = 0.5
        usernameTextField.activeLineColor = .watermelon
        usernameTextField.activeLineWidth = 0.5
        usernameTextField.font = .roboto(.medium, size: 16)
        usernameTextField.autocapitalizationType = .none
        usernameTextField.textColor = .gravel
        usernameTextField.clearButtonMode = .whileEditing
        usernameTextField.keyboardType = .asciiCapable
        
        usernameTextField.placeholderText = "Alamat email atau nama pengguna"
        usernameTextField.placeholderColor = .ashGrey
        usernameTextField.placeholderLabel.font = .roboto(.regular, size: 16)
        
        usernameContainerStackView.addArrangedSubview(usernameTextField)
        usernameTextField.anchors.height.equal(40)
    }
    
    func configurePasswordTextField() {
        passwordTextField.font = .roboto(.medium, size: 16)
        passwordTextField.autocapitalizationType = .none
        passwordTextField.textColor = .gravel
        passwordTextField.lineColor = .boulder
        passwordTextField.lineWidth = 0.5
        passwordTextField.activeLineColor = .watermelon
        passwordTextField.activeLineWidth = 0.5
        passwordTextField.keyboardType = .asciiCapable
        
        passwordTextField.placeholderText = "Kata sandi"
        passwordTextField.placeholderColor = .ashGrey
        passwordTextField.placeholderLabel.font = .roboto(.regular, size: 16)
        
        passwordContainerStackView.addArrangedSubview(passwordTextField)
        passwordTextField.anchors.height.equal(40)
    }
    
    func configureForgotPasswordButton() {
        forgotPasswordButton.titleLabel?.font = .roboto(.medium, size: 14)
        forgotPasswordButton.setTitle("Lupa kata sandi?", for: .normal)
        forgotPasswordButton.setTitleColor(.night, for: .normal)
        forgotPasswordButton.contentHorizontalAlignment = .leading
        
        forgotPasswordButton.tapPublisher
            .sink { [weak self] _ in self?.forgotPasswordButtonCallback?() }
            .store(in: &cancellables)
        
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(forgotPasswordButton)
    }
    
    func configureLoginButton() {
        loginButton.indicator = MaterialLoadingIndicatorSimple(radius: 10)
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
        
        stackView.addArrangedSubview(spacer(32))
        stackView.addArrangedSubview(loginButton)
        loginButton.anchors.height.equal(40)
    }
    
    func configureErrorLabel() {
        errorView.isHidden = true
        passwordContainerStackView.addArrangedSubview(errorView)
    }
}

// MARK: API
internal extension LoginView {
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            loginButton.showLoader([])
        } else {
            loginButton.hideLoader()
        }
    }
    
    func setErrorMessage(_ message: String?) {
        usernameTextField.isError = true
        passwordTextField.isError = true
        errorView.setErrorText(message)
        loginButton.isEnabled = false
    }
    
    func setFirstResponder() {
        usernameTextField.becomeFirstResponder()
    }
    
    func resignResponder() {
        usernameTextField.resignFirstResponder()
    }
    
    func setAccount(_ account: String) {
        usernameTextField.text = account
        usernameTextField.sendActions(for: .editingChanged)
    }
    
    func setHeadingVisibility(visible isVisible: Bool) {
        headingStackView.isHidden = !isVisible
    }
}
