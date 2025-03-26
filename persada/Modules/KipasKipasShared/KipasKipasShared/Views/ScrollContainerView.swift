import UIKit

public final class ScrollContainerView: UIScrollView {
    
    public var spacingBetween: CGFloat = 0 {
        didSet { stackView.spacing = spacingBetween }
    }
    
    public var isCentered: Bool = false {
        didSet { centeredContentViewAnchor.isActive = isCentered }
    }
    
    public var alignment: UIStackView.Alignment = .fill {
        didSet { stackView.alignment = alignment }
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
        centeredContentViewAnchor = contentView.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        contentView.addSubview(stackView)
        paddingLeftConstraint = stackView.anchors.leading.equal(contentView.anchors.leading, constant: paddingLeft)
        paddingRightConstraint = stackView.anchors.trailing.equal(contentView.anchors.trailing, constant: paddingRight)
        
        stackView.anchors.top.greaterThanOrEqual(contentView.anchors.top)
        stackView.anchors.bottom.lessThanOrEqual(contentView.anchors.bottom)
        stackView.anchors.centerY.align()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @discardableResult
    public func addArrangedSubViews(_ view: UIView) -> Self {
        self.stackView.addArrangedSubview(view)
        return self
    }
}
