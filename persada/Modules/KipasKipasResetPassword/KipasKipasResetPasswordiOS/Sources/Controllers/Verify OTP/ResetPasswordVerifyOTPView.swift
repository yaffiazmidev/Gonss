import UIKit
import Combine
import KipasKipasShared

final class ResetPasswordVerifyOTPView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingLabel = UILabel()
    private let subheadingLabel = UILabel()
    private let otpView = SVPinView()
    
    private let resendOTPButton = KKBaseButton()
    private let timerLabel = UILabel()
    private let loadingIndicator = MaterialLoadingIndicatorSimple(radius: 10)
    
    private let errorView = ErrorMessageView()
    private let resendOTPStackView = UIStackView()
    
    private var cancellables = Set<AnyCancellable>()
    
    var didFinishInputOTP: ((String) -> Void)?
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
            
            errorView.isHidden = true
        }
        
        otpView.didFinishCallback = { [weak self] otp in
            self?.didFinishInputOTP?(otp)
        }
        
        resendOTPButton.tapPublisher
            .sink { [weak self] in
                self?.didTapResendOTP?()
                self?.setErrorMessage(nil)
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension ResetPasswordVerifyOTPView {
    func setLoading(_ isLoading: Bool) {
        
        otpView.isUserInteractionEnabled = !isLoading
        
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.finish {
                self.configureLoadingIndicator()
            }
        }
    }
    
    func setTimerText(
        _ text: String,
        isTimerEnded: Bool
    ) {
        timerLabel.text = text
        timerLabel.isHidden = isTimerEnded
        resendOTPButton.isEnabled = isTimerEnded
        resendOTPButton.titleLabel?.font = .roboto(isTimerEnded ? .medium : .regular, size: 14)
        resendOTPStackView.isHidden = false
    }
    
    func showRequestedTooManyOTPError() {
        resendOTPButton.isEnabled = false
        setErrorMessage("Anda mengirimkan terlalu banyak kode verifikasi. Segera coba lagi.")
    }
   
    func setErrorMessage(_ text: String?) {
        errorView.setErrorText(text)
    }
    
    func setHeadingText(_ text: String) {
        headingLabel.text = text
    }
    
    func setSubheadingText(_ text: String) {
        subheadingLabel.text = text
    }
    
    func setOTP(_ otp: String) {
        otpView.pastePin(pin: otp)
    }
}

// MARK: UI
private extension ResetPasswordVerifyOTPView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingLabel()
        configureOTPView()
        configureErrorView()
        configureResendOTPStackView()
        configureLoadingIndicator()
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
        headingLabel.font = .roboto(.bold, size: 20)
        headingLabel.textColor = .night
        
        subheadingLabel.font = .roboto(.regular, size: 14)
        subheadingLabel.textColor = .boulder
        subheadingLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(subheadingLabel)
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
    
    func configureLoadingIndicator() {
        loadingIndicator.color = .ashGrey
        resendOTPStackView.addSubview(loadingIndicator)
        
        loadingIndicator.anchors.centerY.align()
        loadingIndicator.anchors.trailing.pin(inset: 16)
    }
}
