import UIKit
import Combine
import KipasKipasShared

final class ResetPasswordView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingLabel = UILabel()
    
    private let passwordTextField = KKPasswordUnderlinedTextField()
    private let inputCriteriaView = InputCriteriaListView()
    
    private let errorView = ErrorMessageView()
    
    private lazy var passwordLengthCriteriaView = InputCriteriaView(title: "8 karakter (maks. 20)")
    private lazy var containsCapitalCriteriaView = InputCriteriaView(title: "Kombinasi huruf kecil dan kapital")
    private lazy var containsNumberCriteriaView = InputCriteriaView(title: "1 angka")
    
    private let loginButton = KKLoadingButton()
   
    private var cancellables = Set<AnyCancellable>()
    
    var onTapNext: ((String) -> Void)?
    
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
        let lengthValidator = TextLengthValidator(min: 8, max: 20, inputType: .char)
        let containsCapitalValidator = ContainsLowercaseAndUppercaseLetter()
        let containsNumberValidator = ContainsNumberValidator()
        
        passwordTextField
            .validationPublisher(with: lengthValidator)
            .sink {  [weak self] result in
                guard let self = self else { return }
                passwordLengthCriteriaView.isValid = result.isValid
            }
            .store(in: &cancellables)
        
        passwordTextField
            .validationPublisher(with: containsCapitalValidator)
            .sink { [weak self] result in
                guard let self = self else { return }
                containsCapitalCriteriaView.isValid = result.isValid
            }
            .store(in: &cancellables)
        
        passwordTextField
            .validationPublisher(with: containsNumberValidator)
            .sink { [weak self] result in
                guard let self = self else { return }
                containsNumberCriteriaView.isValid = result.isValid
            }
            .store(in: &cancellables)
        
        passwordTextField
            .validationPublisher(
                with: Validators.CombineThree(
                    lengthValidator,
                    containsCapitalValidator,
                    containsNumberValidator
                )
            )
            .sink { [weak self] result in
                guard let self = self else { return }
                passwordTextField.text = result.value.trimmingCharacters(in: .whitespaces)
                loginButton.isEnabled = result.isValid
            }
            .store(in: &cancellables)
        
        loginButton.tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                if let text = passwordTextField.text {
                    onTapNext?(text)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension ResetPasswordView {
    func setLoading(_ isLoading: Bool) {
        passwordTextField.isEnabled = !isLoading
        
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
}

// MARK: UI
private extension ResetPasswordView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingLabel()
        configurePasswordTextField()
        configureErrorView()
        configureInputCriteriaView()
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
        headingLabel.text = "Reset kata sandi"
        headingLabel.font = .roboto(.bold, size: 20)
        headingLabel.textColor = .night

        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(spacer(12))
    }
    
    func configurePasswordTextField() {
        passwordTextField.lineColor = .boulder
        passwordTextField.lineWidth = 0.5
        passwordTextField.activeLineColor = .watermelon
        passwordTextField.activeLineWidth = 0.5
        passwordTextField.font = .roboto(.medium, size: 16)
        passwordTextField.autocapitalizationType = .none
        passwordTextField.textColor = .gravel
        passwordTextField.placeholderText = "Masukkan kata sandi"
        passwordTextField.placeholderColor = .ashGrey
        passwordTextField.placeholderLabel.font = .roboto(.regular, size: 16)
      
        stackView.addArrangedSubview(spacer(32))
        stackView.addArrangedSubview(passwordTextField)
        passwordTextField.anchors.height.equal(40)
    }
    
    func configureErrorView() {
        errorView.isHidden = true
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(errorView)
    }
   
    func configureInputCriteriaView() {
        inputCriteriaView.title = "Kata sandi harus memiliki setidaknya:"
        inputCriteriaView.addCriteriaView(passwordLengthCriteriaView)
        inputCriteriaView.addCriteriaView(containsCapitalCriteriaView)
        inputCriteriaView.addCriteriaView(containsNumberCriteriaView)
        
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(inputCriteriaView)
    }
    
    func configureLoginButton() {
        loginButton.indicatorPosition = .right
        loginButton.indicator = MaterialLoadingIndicatorSimple(radius: 10)
        loginButton.setBackgroundColor(.watermelon, for: .normal)
        loginButton.setBackgroundColor(.sweetPink, for: .disabled)
        loginButton.isEnabled = false
        loginButton.indicator.color = .white
        loginButton.titleLabel?.font = .roboto(.bold, size: 14)
        loginButton.setTitle("Masuk", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.clipsToBounds = true
        
        stackView.addArrangedSubview(spacer(40))
        stackView.addArrangedSubview(loginButton)
        
        loginButton.anchors.height.equal(40)
    }
}

