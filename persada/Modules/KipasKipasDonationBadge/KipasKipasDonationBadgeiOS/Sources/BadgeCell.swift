import UIKit
import Kingfisher
import KipasKipasShared
import KipasKipasDonationBadge

final class BadgeCell: UICollectionViewCell, ScaleTransformView {

    var scaleOptions: ScaleTransformViewOptions {
        return .init(
            keepVerticalSpacingEqual: false,
            keepHorizontalSpacingEqual: false
        )
    }
    
    private var badgeHeightConstraint: NSLayoutConstraint!
    private var badgeWidthConstraint: NSLayoutConstraint!
    
    private let badgeCardView = BadgeCardView()
 
    private var messageView: BadgeMessageView {
        badgeCardView.badgeMessageView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(badgeCardView)
        
        badgeCardView.anchors.center.align()
        badgeWidthConstraint = badgeCardView.anchors.width.equal(badgeSize.width)
        badgeHeightConstraint = badgeCardView.anchors.height.equal(badgeSize.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateAdaptedConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    func configure(with badge: BadgeViewModel, delegate: BadgeMessageViewDelegate) {
        badgeCardView.badgeImageView.kf.indicatorType = .activity
        //badgeCardView.badgeImageView.kf.setImage(with: badge.badgeURL, options: [.cacheOriginalImage])
        
        var badgeURLOSS = badge.badgeURL?.absoluteString ?? ""
        badgeURLOSS += "?x-oss-process=image/format,png/resize,w_200"
        
        let badgeURLOSSURL = URL(string: badgeURLOSS)
        
        badgeCardView.badgeImageView.kf.setImage(with: badgeURLOSSURL, options: [.cacheOriginalImage])
        
        badgeCardView.amountRangeLabel.text = badge.badgeAmountRangeDescription
        badgeCardView.badgeNameLabel.text = badge.badgeName
        
        badgeCardView.showBadge(badge.isShowBadge)
        badgeCardView.configureBadgeAppearance(
            badge.isBadgeUnlocked,
            message: badge.badgeMessage,
            highlightedText: badge.highlightedBadgeMessageText
        )
        badgeCardView.setMyBadge(badge.isMyBadge)
        
        messageView.delegate = delegate
    }
    
    func updateBadgeCompleted(_ isSuccess: Bool) {
        messageView.loadingCompleted(isSuccessFull: isSuccess)
    }
}

// MARK: Adaptive Layout
private extension BadgeCell {
    var badgeSize: CGSize {
        resized(size: .init(width: 290, height: 386), basedOn: .height)
    }
    
    func updateBadgeConstraints() {
        badgeWidthConstraint.constant = badgeSize.width
        badgeHeightConstraint.constant = badgeSize.height
    }
}
