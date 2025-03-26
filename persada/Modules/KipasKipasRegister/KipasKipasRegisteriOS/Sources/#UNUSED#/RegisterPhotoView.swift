import UIKit
import Combine
import KipasKipasShared

final class RegisterPhotoView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    private let headingStack = UIStackView()
    
    private let labelStack = UIStackView()
    private let headingLabel = UILabel()
    private let subheadingLabel = UILabel()
   
    private let previewImageView = UIImageView()
    private let fullnameHeadingLabel = UILabel()
    private let fullNameTextField = KKUnderlinedTextField()
    private let fullNameLengthLabel = UILabel()
    
    private let pickerButton = KKBaseButton()
    
    private lazy var loadingView = UIActivityIndicatorView()
    
    var didTapPickButton: (() -> Void)?
    var didTypeFullname: ((String) -> Void)?
    
    private var cancellables: Set<AnyCancellable> = []
    
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
        pickerButton
            .tapPublisher
            .sink { [weak self] in
                self?.didTapPickButton?()
            }
            .store(in: &cancellables)
        
        fullNameTextField
            .editingChangedPublisher
            .sink { [weak self] value in
                let max = min(value.count, 20)
                self?.fullNameLengthLabel.text = "\(max)/20"
                self?.didTypeFullname?(value)
            }
            .store(in: &cancellables)
    }
    
    func setImage(from data: Data?) {
        if let data = data {
            previewImageView.image = UIImage(data: data)
        } else {
            previewImageView.image = .defaultProfileImageLarge
        }
    }
    
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            previewImageView.alpha = 0.5
            loadingView.startAnimating()
        } else {
            previewImageView.alpha = 1
            loadingView.stopAnimating()
        }
    }
}

// MARK: UI
private extension RegisterPhotoView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingStack()
        configurePreviewImageView()
        configureFullNameHeadingLabel()
        configureFullNameTextField()
        configureFullNameLengthLabel()
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
        headingLabel.text = "Pasang foto"
        headingLabel.font = .roboto(.medium, size: 18)
        headingLabel.textColor = .night
        
        labelStack.addArrangedSubview(headingLabel)
    }
    
    func configureSubheadingLabel() {
        subheadingLabel.font = .roboto(.regular, size: 14)
        subheadingLabel.textColor = .boulder
        subheadingLabel.numberOfLines = 0
        subheadingLabel.text = "Foto terbaik untuk membuat profilmu lebih menarik"
        
        labelStack.addArrangedSubview(subheadingLabel)
    }
    
    func configureFullNameHeadingLabel() {
        fullnameHeadingLabel.text = "Fullname"
        fullnameHeadingLabel.font = .roboto(.medium, size: 12)
        fullnameHeadingLabel.textColor = .night
        
        stackView.addArrangedSubview(fullnameHeadingLabel)
    }
    
    func configureFullNameTextField() {
        fullNameTextField.lineColor = .boulder
        fullNameTextField.lineWidth = 0.5
        fullNameTextField.activeLineColor = .watermelon
        fullNameTextField.activeLineWidth = 0.5
        fullNameTextField.font = .roboto(.medium, size: 16)
        fullNameTextField.autocapitalizationType = .none
        fullNameTextField.textColor = .gravel
        fullNameTextField.clearButtonMode = .whileEditing
        fullNameTextField.placeholderText = "Masukkan fullname"
        fullNameTextField.placeholderColor = .ashGrey
        fullNameTextField.placeholderLabel.font = .roboto(.regular, size: 16)
        fullNameTextField.delegate = self
        
        stackView.addArrangedSubview(fullNameTextField)
        stackView.addArrangedSubview(spacer(12))
        fullNameTextField.anchors.height.equal(40)
    }
    
    func configureFullNameLengthLabel() {
        fullNameLengthLabel.text = "0/20"
        fullNameLengthLabel.font = .roboto(.regular, size: 12)
        fullNameLengthLabel.textColor = .boulder
        fullNameLengthLabel.textAlignment = .right
        
        stackView.addArrangedSubview(fullNameLengthLabel)
        stackView.addArrangedSubview(spacer(32))
    }
    
    func configurePreviewImageView() {
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.image = .defaultProfileImageLarge
        previewImageView.backgroundColor = .clear
        previewImageView.layer.cornerRadius = 24
        previewImageView.isUserInteractionEnabled = true
        previewImageView.layer.masksToBounds = true
        
        let container = UIView()
        container.isUserInteractionEnabled = true

        container.addSubview(previewImageView)
        previewImageView.anchors.width.equal(140)
        previewImageView.anchors.height.equal(140)
        previewImageView.anchors.center.align()
        
        stackView.addArrangedSubview(spacer(40))
        stackView.addArrangedSubview(container)
        container.anchors.height.equal(200)
        container.bringSubviewToFront(previewImageView)
        
        configurePickerButton()
        configureLoadingView()
    }
    
    func configureLoadingView() {
        loadingView.color = .white
        
        previewImageView.addSubview(loadingView)
        loadingView.anchors.center.align()
    }
    
    func configurePickerButton() {
        pickerButton.imageView?.contentMode = .center
        pickerButton.setImage(UIImage.iconCamera?.withTintColor(.white))
        pickerButton.backgroundColor = .azure
        pickerButton.layer.cornerRadius = 36 / 2
        pickerButton.layer.borderColor = UIColor.white.cgColor
        pickerButton.layer.borderWidth = 4
        pickerButton.clipsToBounds = true
        
        addSubview(pickerButton)
        pickerButton.anchors.width.equal(36)
        pickerButton.anchors.height.equal(36)
        pickerButton.anchors.centerY.equal(previewImageView.anchors.bottom, constant: -10)
        pickerButton.anchors.centerX.equal(previewImageView.anchors.trailing, constant: -10)
    }
}

extension RegisterPhotoView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let newLength = text.count + string.count - range.length
        return newLength <= 20
    }
}
