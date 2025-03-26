import UIKit
import KipasKipasShared

protocol BadgeMessageViewDelegate: AnyObject {
    func onSwitchUpdate(_ isShowBadge: Bool)
}

final class BadgeMessageView: UIView {
    
    var isShowBadge: Bool = false {
        didSet { updateAppearance() }
    }
    
    var isMyBadge: Bool = false {
        didSet { updateAppearance() }
    }
    
    var isBadgeUnlocked: Bool = false {
        didSet { updateAppearance() }
    }
    
    var attributedMessage: NSMutableAttributedString? {
        didSet {
            messageLabel.attributedText = attributedMessage
        }
    }
    
    weak var delegate: BadgeMessageViewDelegate?
    
    private let stackContainer = UIStackView()
    private let switchControl = KKSwitch()
    private let messageLabel = UILabel()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateAdaptedConstraints()
    }
    
    func loadingCompleted(isSuccessFull: Bool) {
        switchControl.loadingCompleted(isSuccessFull: isSuccessFull)
    }
}

private extension BadgeMessageView {
    func configureUI() {
        configureStackContainer()
        configureSwitchControl()
        configureMessageLabel()
    }
    
    func configureStackContainer() {
        stackContainer.distribution = .fill
        stackContainer.alignment = .center
        stackContainer.spacing = stackSpacing
        
        addSubview(stackContainer)
        leadingConstraint = stackContainer.anchors.leading.pin(inset: horizontalSpacing)
        trailingConstraint = stackContainer.anchors.trailing.pin(inset: horizontalSpacing)
        stackContainer.anchors.edges.pin(axis: .vertical)
    }
    
    func configureSwitchControl() {
        switchControl.onTintColor = .azure
        switchControl.isHidden = true
        switchControl.thumbRadiusPadding = 2
        switchControl.isLoadingEnabled = true
        switchControl.loadingColor = .azure
        
        switchControl.valueChange = { [weak self] value in
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            self?.isShowBadge = value
            self?.delegate?.onSwitchUpdate(value)
        }
        
        stackContainer.addArrangedSubview(switchControl)
        switchControl.anchors.width.equal(switchControlSize.width)
        switchControl.anchors.height.equal(switchControlSize.height)
    }
    
    func configureMessageLabel() {
        messageLabel.font = .roboto(.medium, adaptedSize: 12)
        messageLabel.textAlignment = .center
        
        stackContainer.addArrangedSubview(messageLabel)
    }
    
    func updateAppearance() {
        switchControl.isOn = isShowBadge
        
        if isBadgeUnlocked {
            isHidden = isMyBadge == false
            switchControl.isHidden = isMyBadge == false
        } else {
            isHidden = false
        }
        
        backgroundColor = isBadgeUnlocked ? UIColor.white.withAlphaComponent(0.2) : .white
    }
}

// MARK: Adaptive Layout
private extension BadgeMessageView {
    var stackSpacing: CGFloat {
        adapted(dimensionSize: 8, to: .width)
    }
    
    var switchControlSize: CGSize {
        resized(size: .init(width: 30, height: 16), basedOn: .height)
    }
    
    var horizontalSpacing: CGFloat {
        adapted(dimensionSize: 18, to: .height)
    }
}
