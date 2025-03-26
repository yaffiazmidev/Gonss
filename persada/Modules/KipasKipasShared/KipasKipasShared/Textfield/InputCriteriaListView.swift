import UIKit

public final class InputCriteriaListView: UIView {
    
    public var title: String = "" {
        didSet {
            headingLabel.text = title
        }
    }
    
    private let stackView = UIStackView()
    private let headingLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    public func addCriteriaView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
}

private extension InputCriteriaListView {
    func configureUI() {
        configureStackView()
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .top
        
        addSubview(stackView)
        stackView.anchors.edges.pin()
        
        configureHeadingLabel()
    }
    
    func configureHeadingLabel() {
        headingLabel.font = .roboto(.medium, size: 12)
        headingLabel.textColor = .night
        
        stackView.addArrangedSubview(headingLabel)
    }
}

public final class InputCriteriaView: UIView {
    
    public var isValid: Bool = false {
        didSet {
            iconView.image = isValid ? .iconTickActive : .iconTickInactive
            criteriaLabel.textColor = isValid ? .gravel : .ashGrey
        }
    }
    
    private let iconView = UIImageView()
    private let criteriaLabel = UILabel()
    private let stackView = UIStackView()
    
    public init(title: String) {
        super.init(frame: .zero)
        commonInit()
        criteriaLabel.text = title
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func commonInit() {
        configureUI()
        isValid = false
    }
}

private extension InputCriteriaView {
    func configureUI() {
        configureStackView()
    }
    
    func configureStackView() {
        stackView.spacing = 4
        stackView.alignment = .top
        
        addSubview(stackView)
        stackView.anchors.edges.pin()
        
        configureIconView()
        configureCriteriaLabel()
    }
    
    func configureIconView() {
        iconView.image = .iconTickInactive
        iconView.contentMode = .scaleAspectFit
        
        stackView.addArrangedSubview(iconView)
        iconView.anchors.width.equal(16)
        iconView.anchors.height.equal(16)
    }
    
    func configureCriteriaLabel() {
        criteriaLabel.font = .roboto(.regular, size: 12)
        criteriaLabel.textColor = .ashGrey
        criteriaLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(criteriaLabel)
    }
}
