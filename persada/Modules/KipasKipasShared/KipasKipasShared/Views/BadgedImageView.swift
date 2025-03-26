import UIKit

public final class BadgedImageView: UIView {
    
    public var hideRibbon: Bool = false {
        didSet {
            rankRibbonImageView.isHidden = hideRibbon
        }
    }
    
    public var rank: Int = 0 {
        didSet {
            configureAppearanceBasedOnRank()
        }
    }
    
    public var shouldShowBadge: Bool = true {
        didSet {
            if shouldShowBadge == false {
                userImageView.image = .anonimProfilePhoto
            }
        }
    }
    
    public private(set) var badgeImageView = UIImageView()
    public private(set) var userImageView = UIImageView()
    public private(set) var rankRibbonImageView = UIImageView()
    private let rankLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        configureUI()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureAppearanceBasedOnRank() {
        rankLabel.text = String(rank)
        rankLabel.textColor = .white
        
        switch rank {
        case 1:
            rankRibbonImageView.image = .ribbonRank1
            
        case 2:
            rankRibbonImageView.image = .ribbonRank2
            
        case 3:
            rankRibbonImageView.image = .ribbonRank3
            
        default:
            rankRibbonImageView.image = .ribbonRankGlobal
            rankLabel.textColor = .gravel
        }
    }
}

// MARK: UI
private extension BadgedImageView {
    func configureUI() {
        configureUserImageView()
        configureRankRibbonImageView()
        configureBadgeImageView()
        configureBadgeImageView()
        configureRankLabel()
    }
    
    func configureUserImageView() {
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor.carrot.cgColor
        userImageView.layer.cornerRadius = 13
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = .mauve
        
        addSubview(userImageView)
        userImageView.anchors.width.equal(anchors.width * 0.65)
        userImageView.anchors.height.equal(userImageView.anchors.width)
        userImageView.anchors.trailing.pin()
        userImageView.anchors.centerY.align()
    }
    
    func configureRankRibbonImageView() {
        rankRibbonImageView.contentMode = .scaleAspectFit
        
        addSubview(rankRibbonImageView)
        rankRibbonImageView.anchors.width.equal(anchors.width * 0.25)
        rankRibbonImageView.anchors.height.equal(anchors.height * 0.3)
        rankRibbonImageView.anchors.trailing.equal(userImageView.anchors.trailing)
        rankRibbonImageView.anchors.centerY.equal(userImageView.anchors.bottom, constant: -5)
    }
    
    func configureBadgeImageView() {
        badgeImageView.contentMode = .scaleAspectFill
        
        addSubview(badgeImageView)
        badgeImageView.anchors.width.equal(anchors.width * 0.40)
        badgeImageView.anchors.height.equal(anchors.height * 0.425)
        badgeImageView.anchors.centerX.equal(userImageView.anchors.leading)
        badgeImageView.anchors.top.pin()
    }
    
    func configureRankLabel() {
        rankLabel.font = .roboto(.medium, size: 9)
        
        rankRibbonImageView.addSubview(rankLabel)
        rankLabel.anchors.centerX.align()
        rankLabel.anchors.top.pin(inset: 5)
    }
}
