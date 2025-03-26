import UIKit
import Combine
import KipasKipasShared

final class RegisterUsernameView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    private let headingStack = UIStackView()
    
    private let labelStack = UIStackView()
    private let headingLabel = UILabel()
    private let subheadingLabel = UILabel()
    
    private let usernameTextField = KKUnderlinedTextField()
    private let errorLabel = UILabel()
    
    private let inputCriteriaView = InputCriteriaListView()
    
    private lazy var usernameLengthCriteriaView = InputCriteriaView(title: "4 karakter (maks. 20)")
    private lazy var containsLetterCriteriaView = InputCriteriaView(title: "Tidak boleh hanya angka")
    private lazy var noSymbolsAndSpacesCriteriaView = InputCriteriaView(title: "Tidak terdapat simbol dan spasi")
    private lazy var specialCharCriteriaView = InputCriteriaView(title: "Boleh menggunakan underscore (_) dan titik (.), namun tidak boleh diletakkan paling depan atau belakang")
    
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
        let lengthValidator = TextLengthValidator(min: 4, max: 20, inputType: .char)
        let containsLetterValidator = ContainsLetterValidator()
        let usernameSpecialCharValidator = UsernameSpecialCharValidator()
        let noSymbolsAndSpacesValidator = NoSymbolsAndSpacesValidator()
        
        usernameTextField
            .validationPublisher(with: lengthValidator)
            .sink {  [weak self] result in
                guard let self = self else { return }
                usernameLengthCriteriaView.isValid = result.isValid
            }
            .store(in: &cancellables)
        
        usernameTextField
            .validationPublisher(with: containsLetterValidator)
            .sink { [weak self] result in
                guard let self = self else { return }
                containsLetterCriteriaView.isValid = result.isValid
            }
            .store(in: &cancellables)
        
        usernameTextField
            .validationPublisher(with: noSymbolsAndSpacesValidator)
            .sink { [weak self] result in
                guard let self = self else { return }
                noSymbolsAndSpacesCriteriaView.isValid = result.isValid
            }
            .store(in: &cancellables)
        
        usernameTextField
            .validationPublisher(with: usernameSpecialCharValidator)
            .sink { [weak self] result in
                guard let self = self else { return }
                specialCharCriteriaView.isValid = result.isValid
            }
            .store(in: &cancellables)
    
        usernameTextField
            .validationPublisher(
                with: Validators.CombineTwo(
                    Validators.CombineTwo(
                        lengthValidator,
                        containsLetterValidator
                    ),
                    Validators.CombineTwo(
                        noSymbolsAndSpacesValidator,
                        usernameSpecialCharValidator
                    )
                )
            )
            .sink { [weak self] result in
                guard let self = self else { return }
                errorLabel.isHidden = true
                nextButton.isEnabled = result.isValid
                usernameTextField.text = result.value.lowercased()
            }
            .store(in: &cancellables)
        
        nextButton.tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                if let text = usernameTextField.text {
                    onTapNext?(text)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: API
extension RegisterUsernameView {
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            nextButton.showLoader([])
        } else {
            nextButton.hideLoader()
        }
    }
    
    func setErrorText(
        _ text: String
    ) {
        errorLabel.text = text
        errorLabel.isHidden = false
        nextButton.isEnabled = false
    }
}

// MARK: UI
private extension RegisterUsernameView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingStack()
        configureUsernameTextField()
        configureErrorLabel()
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
    
    func configureHeadingStack() {
        headingStack.distribution = .equalSpacing
        headingStack.alignment = .top
        
        stackView.addArrangedSubview(headingStack)
        
        configureLabelStack()
    }
    
    func configureLabelStack() {
        labelStack.axis = .vertical
        labelStack.spacing = 8
        
        headingStack.addArrangedSubview(labelStack)
        
        configureHeadingLabel()
        configureSubheadingLabel()
    }
    
    func configureHeadingLabel() {
        headingLabel.text = "Buat username"
        headingLabel.font = .roboto(.medium, size: 18)
        headingLabel.textColor = .night
        
        labelStack.addArrangedSubview(headingLabel)
    }
    
    func configureSubheadingLabel() {
        subheadingLabel.font = .roboto(.regular, size: 14)
        subheadingLabel.textColor = .boulder
        subheadingLabel.numberOfLines = 0
        subheadingLabel.text = "Kamu dapat mengubahnya lagi nanti"
        
        labelStack.addArrangedSubview(subheadingLabel)
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
        usernameTextField.placeholderText = "Masukkan username"
        usernameTextField.placeholderColor = .ashGrey
        usernameTextField.placeholderLabel.font = .roboto(.regular, size: 16)
      
        stackView.addArrangedSubview(spacer(34))
        stackView.addArrangedSubview(usernameTextField)
        usernameTextField.anchors.height.equal(40)
    }
    
    func configureErrorLabel() {
        errorLabel.font = .roboto(.regular, size: 12)
        errorLabel.textColor = .brightRed
        errorLabel.isHidden = true
        errorLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(spacer(10))
        stackView.addArrangedSubview(errorLabel)
    }
   
    func configureInputCriteriaView() {
        inputCriteriaView.title = "Username harus memenuhi:"
        inputCriteriaView.addCriteriaView(usernameLengthCriteriaView)
        inputCriteriaView.addCriteriaView(containsLetterCriteriaView)
        inputCriteriaView.addCriteriaView(noSymbolsAndSpacesCriteriaView)
        inputCriteriaView.addCriteriaView(specialCharCriteriaView)
        
        stackView.addArrangedSubview(spacer(12))
        stackView.addArrangedSubview(inputCriteriaView)
    }
    
    func configureNextButton() {
        nextButton.indicator = MaterialLoadingIndicatorSimple(radius: 10.0)
        nextButton.indicatorPosition = .right
        nextButton.setBackgroundColor(.watermelon, for: .normal)
        nextButton.setBackgroundColor(.sweetPink, for: .disabled)
        nextButton.isEnabled = false
        nextButton.indicator.color = .white
        nextButton.titleLabel?.font = .roboto(.bold, size: 14)
        nextButton.setTitle("Let's Go!", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 8
        nextButton.clipsToBounds = true
        
        stackView.addArrangedSubview(spacer(40))
        stackView.addArrangedSubview(nextButton)
        
        nextButton.anchors.height.equal(40)
    }
}

