import UIKit
import KipasKipasShared

final class BadgeCardView: UIView {
    
    private let containerView = UIView()
    private let stackContainerView = ScrollContainerView()
    
    private var badgeImageHeightConstraint: NSLayoutConstraint!
    
    private(set) var badgeImageView = UIImageView()
    private(set) var amountRangeLabel = UILabel()
    private(set) var badgeNameLabel = UILabel()
    private(set) var badgeMessageView = BadgeMessageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContainerView()
        configureStackContainerView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.721, green: 0, blue: 0.783, alpha: 1).cgColor,
            UIColor(red: 0.155, green: 0, blue: 0.483, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.6, y: 0.6)
        gradientLayer.bounds = bounds.insetBy(dx: -0.5*bounds.size.width , dy: -0.5*bounds.size.height)
        gradientLayer.position = center
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 20
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        updateAdaptedConstraints()
    }
    
    func showBadge(_ isShowBadge: Bool) {
        badgeMessageView.isShowBadge = isShowBadge
    }
    
    func setMyBadge(_ isMyBadge: Bool) {
        badgeMessageView.isMyBadge = isMyBadge
    }
    
    func configureBadgeAppearance(_ isBadgeUnlocked: Bool, message: String, highlightedText: String) {
        let color = isBadgeUnlocked ? .softPeach : UIColor.softPeach.withAlphaComponent(0.3)
        amountRangeLabel.textColor = color
        badgeNameLabel.textColor = color
        
        let range = (message as NSString).range(of: highlightedText)
        let attributedMessage = NSMutableAttributedString(
            string: message,
            attributes: [
                .foregroundColor: isBadgeUnlocked ? UIColor.white : UIColor.gravel,
                .font: UIFont.roboto(.regular, size: 11)
            ]
        )
        attributedMessage.addAttribute(.foregroundColor, value: UIColor.watermelon, range: range)
        attributedMessage.addAttribute(.font, value: UIFont.roboto(.bold, size: 11), range: range)
        
        badgeMessageView.attributedMessage = attributedMessage
        badgeMessageView.isBadgeUnlocked = isBadgeUnlocked
    }
}

// MARK: UI
extension BadgeCardView {
    func configureContainerView() {
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func configureStackContainerView() {
        stackContainerView.isScrollEnabled = false
        stackContainerView.spacingBetween = spacingBetween
        
        containerView.addSubview(stackContainerView)
        stackContainerView.anchors.edges.pin()
        
        configureBadgeImageView()
        configureAmountRangeLabel()
        configureUsernameLabel()
        configureBadgeMessageView()
    }
    
    func configureBadgeImageView() {
        badgeImageView.contentMode = .scaleAspectFit
        
        let topSpacer = UIView()
        topSpacer.backgroundColor = .clear
        topSpacer.anchors.height.equal(topSpace)
        
        stackContainerView.addArrangedSubViews(topSpacer)
        stackContainerView.addArrangedSubViews(badgeImageView)
        badgeImageHeightConstraint = badgeImageView.anchors.height.equal(badgeImageSize.height)
    }
    
    func configureAmountRangeLabel() {
        amountRangeLabel.font = .roboto(.medium, size: 9)
        amountRangeLabel.textAlignment = .center
        
        stackContainerView.addArrangedSubViews(amountRangeLabel)
    }
    
    func configureUsernameLabel() {
        badgeNameLabel.adjustsFontSizeToFitWidth = true
        badgeNameLabel.font = .rye(.regular, adaptedSize: 22)
        badgeNameLabel.textAlignment = .center
        
        stackContainerView.addArrangedSubViews(badgeNameLabel)
    }
    
    func configureBadgeMessageView() {
        stackContainerView.addArrangedSubViews(badgeMessageView)
        badgeMessageView.anchors.height.equal(30)
    }
}

// MARK: Adaptive Layout
private extension BadgeCardView {
    var topSpace: CGFloat {
        adapted(dimensionSize: 30, to: .height)
    }
    
    var spacingBetween: CGFloat {
        adapted(dimensionSize: 16, to: .height)
    }
    
    var badgeImageSize: CGSize {
        resized(size: .init(width: 185, height: 185), basedOn: .height)
    }
}
