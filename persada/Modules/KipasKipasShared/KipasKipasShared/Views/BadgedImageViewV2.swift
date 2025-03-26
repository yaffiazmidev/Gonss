import UIKit

public final class BadgedImageViewV2: UIView {
    
    public var shouldShowBadge: Bool = true {
        didSet {
            if shouldShowBadge == false {
                userImageView.image = .anonimProfilePhoto
            }
        }
    }
    
    public private(set) var badgeImageView = UIImageView()
    public private(set) var userImageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        configureUI()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
}

// MARK: UI
private extension BadgedImageViewV2 {
    func configureUI() {
        configureUserImageView()
        configureBadgeImageView()
    }
    
    func configureUserImageView() {
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor.carrot.cgColor
        userImageView.layer.cornerRadius = 13
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = .porcelain
        
        addSubview(userImageView)
        userImageView.anchors.width.equal(anchors.width)
        userImageView.anchors.height.equal(userImageView.anchors.width)
        userImageView.anchors.trailing.pin()
        userImageView.anchors.centerY.align()
    }
    
    func configureBadgeImageView() {
        badgeImageView.contentMode = .scaleAspectFit
        badgeImageView.isHidden = true
        
        addSubview(badgeImageView)
        badgeImageView.anchors.width.equal(anchors.width * 0.5)
        badgeImageView.anchors.height.equal(anchors.height * 0.5)
        badgeImageView.anchors.centerX.equal(userImageView.anchors.trailing, constant: -5)
        badgeImageView.anchors.centerY.equal(userImageView.anchors.bottom, constant: -5)
    }
    
}
