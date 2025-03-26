import UIKit
import Combine
import KipasKipasShared

final class BirthdayPickerView: UIView {
    
    private let container = UIView()
    private let stackView = UIStackView()
    private let headingStack = UIStackView()
    
    private let labelStack = UIStackView()
    private let headingLabel = UILabel()
    private let subheadingLabel = UILabel()
    private let imageView = UIImageView()
    
    private let dateTextField = KKUnderlinedTextField()
    
    private(set) lazy var nextButton = KKLoadingButton()
       
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    func setDateText(
        _ text: String
    ) {
        dateTextField.text = text
    }
}

// MARK: UI
private extension BirthdayPickerView {
    func configureUI() {
        configureContainerView()
        configureStackView()
        configureHeadingStack()
        configureDateTextField()
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
        configureImageView()
    }
    
    func configureLabelStack() {
        labelStack.axis = .vertical
        labelStack.spacing = 8
        
        headingStack.addArrangedSubview(labelStack)
        
        configureHeadingLabel()
        configureSubheadingLabel()
    }
    
    func configureHeadingLabel() {
        headingLabel.text = "Kapan kamu lahir?"
        headingLabel.font = .roboto(.medium, size: 18)
        headingLabel.textColor = .night
        
        labelStack.addArrangedSubview(headingLabel)
    }
    
    func configureSubheadingLabel() {
        subheadingLabel.text = "Tanggal lahirmu tidak akan di tampilkan ke publik."
        subheadingLabel.font = .roboto(.regular, size: 14)
        subheadingLabel.textColor = .boulder
        subheadingLabel.numberOfLines = 0
        
        labelStack.addArrangedSubview(subheadingLabel)
    }
    
    func configureImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.image = .illustrationTart
        
        headingStack.addArrangedSubview(imageView)
    }
    
    func configureDateTextField() {
        dateTextField.lineColor = .boulder
        dateTextField.lineWidth = 0.5
        dateTextField.activeLineColor = .watermelon
        dateTextField.activeLineWidth = 0.5
        dateTextField.font = .roboto(.medium, size: 16)
        dateTextField.autocapitalizationType = .none
        dateTextField.textColor = .gravel
        dateTextField.isEnabled = false
        dateTextField.placeholderText = "Tanggal Lahir"
        dateTextField.placeholderColor = .ashGrey
        dateTextField.placeholderLabel.font = .roboto(.regular, size: 16)
        
        let calendarIcon = UIImageView(image: .iconCalendar)
        calendarIcon.anchors.width.equal(16)
        calendarIcon.anchors.height.equal(16)
        
        dateTextField.rightViewMode = .always
        dateTextField.rightView = calendarIcon
        
        stackView.addArrangedSubview(spacer(34))
        stackView.addArrangedSubview(dateTextField)
        dateTextField.anchors.height.equal(40)
    }
   
    func configureNextButton() {
        nextButton.setBackgroundColor(.watermelon, for: .normal)
        nextButton.setBackgroundColor(.sweetPink, for: .disabled)
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
