import UIKit
import Combine
import KipasKipasShared

final class LoginOTPRequestView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let phoneTextField = KKPhoneNumberTextField()
    private let sendOTPButton = KKLoadingButton()
    
    private let errorView = ErrorMessageView()
    
    private var cancellables = Set<AnyCancellable>()
    
    var sendOTPButtonCallback: Closure<Phone>?
    
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
                    IndonesiaPhoneNumberValidator(message: "Masukkan nomor telepon yang valid")
                ),
                TextLengthValidator(min: 9, max: 14, inputType: .number, message: "")
            )
        )
        
        phoneValidationPublisher
            .sink { [weak self] phone in
                guard let self = self else { return }
                
                let isValid = phone.isValid
                
                phoneTextField.text = phone.value
                sendOTPButton.isEnabled = isValid
                errorView.setErrorText(phone.error?.message)
            }
            .store(in: &cancellables)
        
        sendOTPButton
            .tapPublisher
            .withLatestFrom(phoneValidationPublisher)
            .sink { [weak self] phone in
                self?.sendOTPButtonCallback?(phone.value)
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension LoginOTPRequestView {
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            sendOTPButton.showLoader([])
        } else {
            sendOTPButton.hideLoader()
        }
    }
    
    func setErrorText(_ text: String) {
        errorView.setErrorText(text)
        sendOTPButton.isEnabled = false
    }
    
    func showRequestedTooManyOTPError() {
        setErrorText("Anda mengirimkan terlalu banyak kode verifikasi. Segera coba lagi.")
    }
    
    func setFirstResponder() {
        phoneTextField.becomeFirstResponder()
    }
    
    func resignResponder() {
        phoneTextField.resignFirstResponder()
    }
}

// MARK: UI
private extension LoginOTPRequestView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configurePhoneTextField()
        configureErrorView()
        configureLoginButton()
    }
    
    func configureContainerView() {
        container.clipsToBounds = true
        
        addSubview(container)
        container.anchors.edges.pin()
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        stackView.spacing = 11
        
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
    
    func configureLoginButton() {
        sendOTPButton.indicator = MaterialLoadingIndicatorSimple(radius: 10.0)
        sendOTPButton.indicatorPosition = .right
        sendOTPButton.setBackgroundColor(.watermelon, for: .normal)
        sendOTPButton.setBackgroundColor(.snowDrift, for: .disabled)
        sendOTPButton.indicator.color = .white
        sendOTPButton.isEnabled = false
        sendOTPButton.titleLabel?.font = .roboto(.bold, size: 16)
        sendOTPButton.setTitle("Kirim kode", for: .normal)
        sendOTPButton.setTitleColor(.white, for: .normal)
        sendOTPButton.setTitleColor(.ashGrey, for: .disabled)
        sendOTPButton.layer.cornerRadius = 4
        sendOTPButton.clipsToBounds = true
       
        stackView.addArrangedSubview(spacer(32))
        stackView.addArrangedSubview(sendOTPButton)
        
        sendOTPButton.anchors.height.equal(40)
    }
    
    func configureErrorView() {
        errorView.isHidden = true
        stackView.addArrangedSubview(errorView)
    }
}
