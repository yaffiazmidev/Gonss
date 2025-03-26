import UIKit
import Combine
import KipasKipasShared
import KipasKipasSharedFoundation

final class RegisterEmailView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let emailTextField = KKUnderlinedTextField()
    private let submitButton = KKLoadingButton()
    
    private let errorView = ErrorMessageView()
    private let infoLabel = InteractiveLabel()
    
    private var cancellables = Set<AnyCancellable>()
    
    var didTapSubmit: Closure<String>?
    var didTapLearnMore: EmptyClosure?
    
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
                submitButton.isEnabled = isValid
                errorView.setErrorText(email.error?.message)
            }
            .store(in: &cancellables)
        
        submitButton
            .tapPublisher
            .withLatestFrom(emailValidationPublisher)
            .sink { [weak self] email in
                self?.didTapSubmit?(email.value)
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension RegisterEmailView {
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            submitButton.showLoader([])
        } else {
            submitButton.hideLoader()
        }
    }
    
    func setErrorText(_ text: String) {
        errorView.setErrorText(text)
        submitButton.isEnabled = false
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
private extension RegisterEmailView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureEmailTextField()
        configureErrorView()
        configureInfoLabel()
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
        
        stackView.addArrangedSubview(emailTextField)
        emailTextField.anchors.height.equal(40)
    }
    
    func configureResetButton() {
        submitButton.indicator = MaterialLoadingIndicatorSimple(radius: 10.0)
        submitButton.indicatorPosition = .right
        submitButton.setBackgroundColor(.watermelon, for: .normal)
        submitButton.setBackgroundColor(.snowDrift, for: .disabled)
        submitButton.indicator.color = .white
        submitButton.isEnabled = false
        submitButton.titleLabel?.font = .roboto(.bold, size: 16)
        submitButton.setTitle("Lanjutkan", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitleColor(.ashGrey, for: .disabled)
        submitButton.layer.cornerRadius = 4
        submitButton.clipsToBounds = true
        
        stackView.addArrangedSubview(spacer(32))
        stackView.addArrangedSubview(submitButton)
        
        submitButton.anchors.height.equal(40)
    }
    
    func configureErrorView() {
        errorView.isHidden = true
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(errorView)
    }
    
    func configureInfoLabel() {
        let customType: InteractiveLabelType = .custom(pattern: "Pelajari Selengkapnya")
        infoLabel.enabledTypes = [customType]
        infoLabel.text = "Alamat email kamu dapat digunakan untuk menghubungkan kamu dengan orang yang mungkin kamu kenal, menyempurnakan iklan, dll., bergantung pada pengaturan kamu. Pelajari selengkapnya."
        infoLabel.customColor[customType] = .night
        infoLabel.handleCustomTap(for: customType) { [weak self] _ in
            self?.didTapLearnMore?()
        }
        
        infoLabel.font = .roboto(.regular, size: 13)
        infoLabel.highlightedFont = UIFont.roboto(.bold, size: 13)
        infoLabel.textColor = .boulder
        infoLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(infoLabel)
    }
}
