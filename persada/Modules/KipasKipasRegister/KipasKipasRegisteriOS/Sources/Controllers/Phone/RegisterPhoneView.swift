import UIKit
import Combine
import KipasKipasShared

final class RegisterPhoneView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let phoneTextField = KKPhoneNumberTextField()
    private let infoLabel = UILabel()
    
    private let sendOTPButton = KKLoadingButton()
    private let switchMethodButton = KKBaseButton()
    private let switchMethodStack = UIStackView()
    
    private let errorView = ErrorMessageView()
    private let loginCTAStackView = UIStackView()
    
    private var cancellables = Set<AnyCancellable>()
    
    var sendOTPButtonCallback: ((_ phone: String) -> Void)?
    var loginButtonCallback: (() -> Void)?
    var switchOTPMethodCallback: (() -> Void)?
    
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
        let phoneValidationPublisher = phoneTextField.validationPublisher(
            with: Validators.CombineThree(
                NonEmptyValidator(errorMessage: "Harap masukkan nomor telepon"),
                Validators.CombineTwo(
                    PhoneNumberOnlyValidator(),
                    IndonesiaPhoneNumberValidator()
                ),
                TextLengthValidator(min: 9, max: 14, inputType: .number)
            )
        )
        
        phoneValidationPublisher
            .sink { [weak self] phone in
                guard let self = self else { return }
                
                let isValid = phone.isValid
                
                phoneTextField.text = phone.value
                sendOTPButton.isEnabled = isValid
                errorView.setErrorText(phone.error?.message)
                
                switchMethodStack.isHidden = true
            }
            .store(in: &cancellables)
        
        sendOTPButton
            .tapPublisher
            .withLatestFrom(phoneValidationPublisher)
            .sink { [weak self] phone in
                self?.sendOTPButtonCallback?(phone.value)
            }
            .store(in: &cancellables)
        
        switchMethodButton
            .tapPublisher
            .sink { [weak self] in
                self?.switchOTPMethodCallback?()
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension RegisterPhoneView {
    func showRequestedTooManyOTPError(method: String, intervalDesc: String) {
        switchMethodStack.isHidden = false
        setErrorText("Kamu sudah melakukan 3x permintaan OTP dengan metode \(method), coba lagi setelah \(intervalDesc)")
    }
    
    func setErrorText(
        _ text: String
    ) {
        errorView.setErrorText(text)
        sendOTPButton.isEnabled = false
    }
    
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            sendOTPButton.showLoader([])
        } else {
            sendOTPButton.hideLoader()
        }
    }
    
    func setFirstResponder() {
        phoneTextField.becomeFirstResponderIfNeeded()
    }
    
    func resignResponder() {
        phoneTextField.resignFirstResponder()
    }
}

// MARK: UI
private extension RegisterPhoneView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configurePhoneTextField()
        configureErrorView()
        configureSwitchMethodButton()
        configureInfoLabel()
        configureLoginButton()
        // configureLoginCTAStackView()
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
    
    func configurePhoneTextField() {
        phoneTextField.lineColor = .boulder
        phoneTextField.lineWidth = 0.5
        phoneTextField.activeLineColor = .watermelon
        phoneTextField.activeLineWidth = 0.5
        phoneTextField.font = .roboto(.medium, size: 16)
        phoneTextField.autocapitalizationType = .none
        phoneTextField.keyboardType = .numberPad
        phoneTextField.clearButtonMode = .whileEditing
        phoneTextField.textColor = .gravel
        
        phoneTextField.placeholderText = "Nomor Telepon"
        phoneTextField.placeholderColor = .ashGrey
        phoneTextField.placeholderLabel.font = .roboto(.regular, size: 16)
        
        stackView.addArrangedSubview(phoneTextField)
        phoneTextField.anchors.height.equal(40)
    }
    
    func configureInfoLabel() {
        infoLabel.text = "Nomor ini mungkin akan digunakan untuk menghubungkan kamu dengan orang-orang yang kamu kenal, meningkatkan iklan dan lainnya."
        infoLabel.font = .roboto(.regular, size: 14)
        infoLabel.textColor = .boulder
        infoLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(infoLabel)
    }
    
    func configureLoginButton() {
        sendOTPButton.indicator = MaterialLoadingIndicatorSimple(radius: 10.0)
        sendOTPButton.indicatorPosition = .right
        sendOTPButton.setBackgroundColor(.watermelon, for: .normal)
        sendOTPButton.setBackgroundColor(.snowDrift, for: .disabled)
        sendOTPButton.isEnabled = false
        sendOTPButton.indicator.color = .white
        sendOTPButton.titleLabel?.font = .roboto(.bold, size: 14)
        sendOTPButton.setTitle("Kirim Kode", for: .normal)
        sendOTPButton.setTitleColor(.white, for: .normal)
        sendOTPButton.setTitleColor(.ashGrey, for: .disabled)
        sendOTPButton.layer.cornerRadius = 8
        sendOTPButton.clipsToBounds = true
       
        stackView.addArrangedSubview(spacer(20))
        stackView.addArrangedSubview(sendOTPButton)
        
        sendOTPButton.anchors.height.equal(40)
    }
    
    func configureErrorView() {
        errorView.isHidden = true
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(errorView)
    }
    
    func configureSwitchMethodButton() {
        switchMethodButton.setTitle("Ganti metode lain")
        switchMethodButton.setTitleColor(.azure, for: .normal)
        switchMethodButton.font = .roboto(.medium, size: 14)
        switchMethodButton.contentHorizontalAlignment = .left
    
        switchMethodStack.axis = .vertical
        switchMethodStack.addArrangedSubview(switchMethodButton)
        switchMethodStack.addArrangedSubview(spacer(20))
        switchMethodStack.isHidden = true
        
        stackView.addArrangedSubview(switchMethodStack)
    }
    
    func configureLoginCTAStackView() {
        let wordingLabel = UILabel()
        wordingLabel.text = "Sudah punya akun?"
        wordingLabel.textColor = .boulder
        wordingLabel.font = .roboto(.regular, size: 14)
        wordingLabel.textAlignment = .right
        
        let loginButton = UIButton()
        loginButton.setTitle("Masuk", for: .normal)
        loginButton.setTitleColor(.watermelon, for: .normal)
        loginButton.titleLabel?.font = .roboto(.medium, size: 14)
        loginButton.contentHorizontalAlignment = .leading
        
        loginButton.tapPublisher
            .sink { [weak self] _ in
                self?.loginButtonCallback?()
            }
            .store(in: &cancellables)
        
        loginCTAStackView.alignment = .center
        loginCTAStackView.distribution = .equalSpacing
        
        loginCTAStackView.addArrangedSubview(wordingLabel)
        loginCTAStackView.addArrangedSubview(loginButton)
        wordingLabel.anchors.width.equal(loginCTAStackView.anchors.width * 0.600)
        loginButton.anchors.width.equal(loginCTAStackView.anchors.width * 0.380)
        
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(loginCTAStackView)
    }
}
