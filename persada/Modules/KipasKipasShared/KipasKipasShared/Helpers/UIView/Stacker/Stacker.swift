import UIKit

public final class Stacker: UIScrollView {
    
    public var spacingBetween: CGFloat = 0 {
        didSet { stackView.spacing = spacingBetween }
    }
    
    public var isCenteredOnly: Bool = false {
        didSet { centeredContentViewAnchor.isActive = isCenteredOnly }
    }
    
    public var alignment: UIStackView.Alignment = .fill {
        didSet {
            switch alignment {
            case .fill:
                topContentViewAnchor.isActive = true
                bottomContentViewAnchor.isActive = true
        
            case .top, .lastBaseline:
                topContentViewAnchor.isActive = true
                bottomContentViewAnchor.isActive = false
                
            case .bottom, .firstBaseline:
                bottomContentViewAnchor.isActive = true
                topContentViewAnchor.isActive = false
                
            case .center:
                centeredContentViewAnchor.isActive = true
                topContentViewAnchor.isActive = true
                bottomContentViewAnchor.isActive = true
                
            default:
                break
            }
        }
    }
    
    private var paddingLeftConstraint: NSLayoutConstraint! {
        didSet { paddingLeftConstraint.isActive = true }
    }
    
    public var paddingLeft: CGFloat = 0.0 {
        didSet { paddingLeftConstraint.constant = paddingLeft }
    }
    
    private var paddingRightConstraint: NSLayoutConstraint! {
        didSet { paddingRightConstraint.isActive = true }
    }
    
    private var centeredContentViewAnchor: NSLayoutConstraint!
    private var topContentViewAnchor: NSLayoutConstraint!
    private var bottomContentViewAnchor: NSLayoutConstraint!
    
    public var paddingRight: CGFloat = 0.0 {
        didSet { paddingRightConstraint.constant = -paddingRight }
    }
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = .clear
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.anchors.edges.pin()
        contentView.anchors.width.equal(anchors.width)
        contentView.anchors.centerY.align()
        
        contentView.addSubview(stackView)
        paddingLeftConstraint = stackView.anchors.leading.equal(contentView.anchors.leading, constant: paddingLeft)
        paddingRightConstraint = stackView.anchors.trailing.equal(contentView.anchors.trailing, constant: paddingRight)
        
        topContentViewAnchor = stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor)
        bottomContentViewAnchor = stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        centeredContentViewAnchor = stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        
        alignment = .fill
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @discardableResult
    public func addArrangedSubViews(_ view: UIView...) -> Self {
        view.forEach { stackView.addArrangedSubview($0) }
        return self
    }
    
    public func insertArrangedSubViews(_ view: UIView, at index: Int = 0) {
        stackView.insertArrangedSubview(view, at: index)
    }
}

