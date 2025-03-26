import UIKit
import Combine
import KipasKipasShared

final class RegisterPasswordView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingLabel = UILabel()
    
    private let passwordTextField = KKPasswordUnderlinedTextField()
    private let inputCriteriaView = InputCriteriaListView()
    
    private lazy var passwordLengthCriteriaView = InputCriteriaView(title: "8 karakter (maks. 20)")
    private lazy var containsCapitalCriteriaView = InputCriteriaView(title: "Kombinasi huruf kecil dan kapital")
    private lazy var containsNumberCriteriaView = InputCriteriaView(title: "1 angka")
    
    private let nextButton = KKLoadingButton()
   
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
                nextButton.isEnabled = result.isValid
            }
            .store(in: &cancellables)
        
        nextButton.tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                if let text = passwordTextField.text {
                    onTapNext?(text)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: UI
private extension RegisterPasswordView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingLabel()
        configurePasswordTextField()
        configureInputCriteriaView()
        configureNextButton()
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
        headingLabel.text = "Buat password"
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
   
    func configureInputCriteriaView() {
        inputCriteriaView.title = "Kata sandi harus memiliki setidaknya:"
        inputCriteriaView.addCriteriaView(passwordLengthCriteriaView)
        inputCriteriaView.addCriteriaView(containsCapitalCriteriaView)
        inputCriteriaView.addCriteriaView(containsNumberCriteriaView)
        
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(inputCriteriaView)
    }
    
    func configureNextButton() {
        nextButton.setBackgroundColor(.watermelon, for: .normal)
        nextButton.setBackgroundColor(.sweetPink, for: .disabled)
        nextButton.isEnabled = false
        nextButton.indicator.color = .white
        nextButton.titleLabel?.font = .roboto(.bold, size: 14)
        nextButton.setTitle("Selanjutnya", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 8
        nextButton.clipsToBounds = true
        
        stackView.addArrangedSubview(spacer(40))
        stackView.addArrangedSubview(nextButton)
        
        nextButton.anchors.height.equal(40)
    }
}

