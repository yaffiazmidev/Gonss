import UIKit
import Combine
import KipasKipasShared

final class ResetPasswordPhoneView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingLabel = UILabel()
    private let subheadingLabel = UILabel()
    
    private let phoneTextField = KKPhoneNumberTextField()
    private let submitButton = KKLoadingButton()
    
    private let errorView = ErrorMessageView()
    
    private var cancellables = Set<AnyCancellable>()
    
    var didTapSubmit: Closure<String>?
    
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
                TextLengthValidator(min: 9, max: 14, inputType: .number, message: "")
            )
        )
        
        phoneValidationPublisher
            .sink { [weak self] phone in
                guard let self = self else { return }
                
                let isValid = phone.isValid
                
                phoneTextField.text = phone.value
                submitButton.isEnabled = isValid
                errorView.setErrorText(phone.error?.message)
            }
            .store(in: &cancellables)
        
        submitButton
            .tapPublisher
            .withLatestFrom(phoneValidationPublisher)
            .sink { [weak self] phone in
                self?.didTapSubmit?(phone.value)
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension ResetPasswordPhoneView {
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
    
    func showRequestedTooManyOTPError() {
        setErrorText("Anda mengirimkan terlalu banyak kode verifikasi. Segera coba lagi.")
    }
}

// MARK: UI
private extension ResetPasswordPhoneView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingLabel()
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
        
        container.addSubview(stackView)
        stackView.anchors.edges.pin()
    }
    
    func configureHeadingLabel() {
        headingLabel.text = "Masukkan nomor telepon kamu"
        headingLabel.font = .roboto(.bold, size: 18)
        headingLabel.textColor = .night
        
        subheadingLabel.text = "Kami akan mengirimkan kode ke ponsel kamu."
        subheadingLabel.font = .roboto(.regular, size: 14)
        subheadingLabel.textColor = .boulder
        
        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(subheadingLabel)
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
        
        stackView.addArrangedSubview(spacer(32))
        stackView.addArrangedSubview(phoneTextField)
        phoneTextField.anchors.height.equal(40)
    }
    
    func configureLoginButton() {
        submitButton.indicator = MaterialLoadingIndicatorSimple(radius: 10.0)
        submitButton.indicatorPosition = .right
        submitButton.setBackgroundColor(.watermelon, for: .normal)
        submitButton.setBackgroundColor(.snowDrift, for: .disabled)
        submitButton.indicator.color = .white
        submitButton.isEnabled = false
        submitButton.titleLabel?.font = .roboto(.bold, size: 16)
        submitButton.setTitle("Kirim kode", for: .normal)
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
}
