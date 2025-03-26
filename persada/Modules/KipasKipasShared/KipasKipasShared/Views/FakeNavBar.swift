import UIKit

open class FakeNavBar: UIView {
  
    public var backgroundImage: UIImage? {
        didSet {
            backgroundImageView.image = backgroundImage
        }
    }
    
    private var settedHeight: CGFloat = 0
    
    public var height: CGFloat {
        get {
            return settedHeight <= 0 ? (statusBarManager?.statusBarFrame.height ?? 0) : settedHeight
        }
        set {
            settedHeight = newValue
            updateHeight()
        }
        
    }
    
    public var isUsingSafeArea: Bool = false {
        didSet {
            layoutIfNeeded()
        }
    }
    
    public var titleHorizontalInsets: CGFloat = 16 {
        didSet {
            titleInsetsConstraints.forEach { $0.constant = titleHorizontalInsets }
        }
    }
    
    private var titleInsetsConstraints: [NSLayoutConstraint] = [] {
        didSet {
            titleInsetsConstraints.forEach { $0.isActive = true }
        }
    }
    
    public private(set) var titleLabel = UILabel()
    public private(set) var leftButton = KKLoadingButton()
    public private(set) var rightButton = KKLoadingButton()
    
    private let backgroundImageView = UIImageView()
    
    public private(set) var separatorView = UIView()
    
    private var heightConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleToFill
        
        addSubview(backgroundImageView)
        backgroundImageView.anchors.edges.pin()
 
        separatorView.backgroundColor = .ashGrey
        
        addSubview(separatorView)
        separatorView.anchors.edges.pin(axis: .horizontal)
        separatorView.anchors.bottom.pin()
        separatorView.anchors.height.equal(0.5)
        
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleInsetsConstraints = titleLabel.anchors.edges.pin(insets: titleHorizontalInsets, axis: .horizontal)
        titleLabel.anchors.center.align()
        
        leftButton.setTitleColor(UIColor.black, for: .normal)
        leftButton.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .highlighted)
        leftButton.titleLabel?.textAlignment = .left
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        addSubview(leftButton)
        leftButton.anchors.leading.pin(inset: 17)
        leftButton.anchors.centerY.align()
        
        rightButton.setTitleColor(UIColor.black, for: .normal)
        rightButton.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .highlighted)
        rightButton.titleLabel?.textAlignment = .right
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        addSubview(rightButton)
        rightButton.anchors.trailing.pin(inset: 17)
        rightButton.anchors.centerY.align()
        
        setContraints()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        setContraints()
    }
    
    private func setContraints() {
        if let superview = self.superview {
            if self.topConstraint == nil {
                
                self.topConstraint = self.topAnchor.constraint(equalTo: isUsingSafeArea ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor)
                self.topConstraint?.isActive = true
                self.leadingConstraint = self.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
                self.leadingConstraint?.isActive = true
                self.trailingConstraint = self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
                self.trailingConstraint?.isActive = true
                
                self.heightConstraint = self.heightAnchor.constraint(equalToConstant: self.height)
                self.heightConstraint?.isActive = true
                self.updateHeight()
            }
        }
    }
    
    private func updateHeight() {
        heightConstraint?.constant = height
        updateConstraints()
    }
}

private extension FakeNavBar {
    var statusBarManager: UIStatusBarManager? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.windowScene?.statusBarManager
    }
}
