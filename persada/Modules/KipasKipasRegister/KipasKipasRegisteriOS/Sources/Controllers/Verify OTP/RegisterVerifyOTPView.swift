import UIKit
import Combine
import KipasKipasShared

final class RegisterVerifyOTPView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingLabel = UILabel()
    private let otpView = SVPinView()
    
    private let verifyOTPButton = KKLoadingButton()
    private let switchOTPButton = KKBaseButton()
    private let resendOTPButton = KKBaseButton()
    private let timerLabel = UILabel()
    
    private let errorView = ErrorMessageView()
    private let resendOTPStackView = UIStackView()
    private let otpMethodStackView = UIStackView()
    
    private var cancellables = Set<AnyCancellable>()
    
    var didFinishInputOTP: ((String) -> Void)?
    var didTapSwitchOTP: (() -> Void)?
    var didTapResendOTP: (() -> Void)?
    
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
        otpView.didChangeCallback = { [weak self] value in
            guard let self = self else { return }
            
            let validator = MinimumLengthValidator(min: 4, errorMessage: "")
            let otp = validator.validate(value)
            
            errorView.isHidden = true
            verifyOTPButton.isEnabled = otp.isValid
        }
        
        resendOTPButton.tapPublisher
            .sink { [weak self] in
                self?.didTapResendOTP?()
                self?.setErrorText(nil)
            }
            .store(in: &cancellables)
        
        switchOTPButton.tapPublisher
            .sink { [weak self] _ in
                self?.didTapSwitchOTP?()
            }
            .store(in: &cancellables)
        
        verifyOTPButton.tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                let otp = otpView.getPin()
                didFinishInputOTP?(otp)
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension RegisterVerifyOTPView {
    func setLoading(_ isLoading: Bool) {
        switchOTPButton.isEnabled = isLoading == false
        
        if isLoading {
            verifyOTPButton.showLoader([])
        } else {
            verifyOTPButton.hideLoader()
        }
    }
    
    func setTimerText(
        _ text: String,
        isTimerEnded: Bool
    ) {
        timerLabel.text = text
        timerLabel.isHidden = isTimerEnded
        resendOTPButton.isEnabled = isTimerEnded
        resendOTPStackView.isHidden = false
        resendOTPButton.titleLabel?.font = .roboto(isTimerEnded ? .medium : .regular, size: 14)
    }
    
    func setErrorTooManyRequest(method: String) {
        resendOTPButton.isEnabled = false
        setErrorText("Kamu sudah melakukan 3x permintaan OTP dengan metode \(method). Segera coba lagi")
    }
    
    func setErrorText(
        _ text: String?
    ) {
        errorView.setErrorText(text)
        verifyOTPButton.isEnabled = false
    }
    
    func resetUI() {
        otpView.clearPin()
        errorView.setErrorText(nil)
    }
}

// MARK: UI
private extension RegisterVerifyOTPView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingLabel()
        configureOTPView()
        configureErrorView()
        configureResendOTPStackView()
       // configureOTPMethodStackView()
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
        headingLabel.text = "Masukkan Kode OTP"
        headingLabel.font = .roboto(.medium, size: 18)
        headingLabel.textColor = .night
        
        stackView.addArrangedSubview(headingLabel)
    }
    
    func configureOTPView() {
        otpView.shouldSecureText = false
        otpView.pinLength = 4
        otpView.interSpace = 50
        otpView.textColor = .gravel
        otpView.borderLineColor = .boulder
        otpView.activeBorderLineColor = .watermelon
        otpView.activeBorderLineThickness = 0.5
        otpView.borderLineThickness = 0.5
        otpView.allowsWhitespaces = false
        otpView.style = .underline
        otpView.fieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
        otpView.activeFieldBackgroundColor = .white
        otpView.fieldCornerRadius = 15
        otpView.activeFieldCornerRadius = 15
        otpView.shouldDismissKeyboardOnEmptyFirstField = false
        otpView.font = .roboto(.medium, size: 19)
        otpView.keyboardType = .phonePad
        otpView.becomeFirstResponderAtIndex = 0
        
        stackView.addArrangedSubview(spacer(22))
        stackView.addArrangedSubview(otpView)
        stackView.addArrangedSubview(spacer(26))
        
        otpView.anchors.height.equal(40)
    }
    
    func configureLoginButton() {
        verifyOTPButton.indicator = MaterialLoadingIndicatorSimple(radius: 10.0)
        verifyOTPButton.indicatorPosition = .right
        verifyOTPButton.setBackgroundColor(.watermelon, for: .normal)
        verifyOTPButton.setBackgroundColor(.sweetPink, for: .disabled)
        verifyOTPButton.isEnabled = false
        verifyOTPButton.indicator.color = .white
        verifyOTPButton.titleLabel?.font = .roboto(.bold, size: 14)
        verifyOTPButton.setTitle("Selanjutnya", for: .normal)
        verifyOTPButton.setTitleColor(.white, for: .normal)
        verifyOTPButton.layer.cornerRadius = 8
        verifyOTPButton.clipsToBounds = true
        
        stackView.addArrangedSubview(spacer(20))
        stackView.addArrangedSubview(verifyOTPButton)
        
        verifyOTPButton.anchors.height.equal(40)
    }
    
    func configureErrorView() {
        errorView.isHidden = true
        stackView.addArrangedSubview(errorView)
        stackView.addArrangedSubview(spacer(10))
    }
    
    func configureResendOTPStackView() {
        resendOTPButton.setTitle("Kirim ulang kode", for: .normal)
        resendOTPButton.setTitleColor(UIColor.watermelon, for: .normal)
        resendOTPButton.setTitleColor(UIColor.gravel.withAlphaComponent(0.5), for: .disabled)
        resendOTPButton.setBackgroundColor(.clear, for: .normal)
        resendOTPButton.setBackgroundColor(.clear, for: .disabled)
        resendOTPButton.titleLabel?.font = .roboto(.regular, size: 14)
        resendOTPButton.contentHorizontalAlignment = .leading
        resendOTPButton.isEnabled = false
        
        timerLabel.font = .roboto(.medium, size: 14)
        timerLabel.textColor = .night
        
        resendOTPStackView.alignment = .center
        resendOTPStackView.distribution = .fill
        resendOTPStackView.spacing = 8
        
        resendOTPStackView.addArrangedSubview(resendOTPButton)
        resendOTPStackView.addArrangedSubview(timerLabel)
        resendOTPStackView.addArrangedSubview(invisibleView())
        
        stackView.addArrangedSubview(resendOTPStackView)
    }
    
    func configureOTPMethodStackView() {
        let wordingLabel = UILabel()
        wordingLabel.text = "Belum menerima kode?"
        wordingLabel.textColor = .night
        wordingLabel.font = .roboto(.regular, size: 14)
        wordingLabel.textAlignment = .left
        
        switchOTPButton.setBackgroundColor(.clear, for: .disabled)
        switchOTPButton.setTitle("Ubah metode", for: .normal)
        switchOTPButton.setTitleColor(.watermelon, for: .normal)
        switchOTPButton.titleLabel?.font = .roboto(.medium, size: 14)
        switchOTPButton.contentHorizontalAlignment = .leading
        
        otpMethodStackView.alignment = .center
        otpMethodStackView.distribution = .fill
        otpMethodStackView.spacing = 8
        
        otpMethodStackView.addArrangedSubview(wordingLabel)
        otpMethodStackView.addArrangedSubview(switchOTPButton)
        otpMethodStackView.addArrangedSubview(invisibleView())
        
        stackView.addArrangedSubview(otpMethodStackView)
    }
}
