import UIKit

@IBDesignable
public final class BadgedProfileImageView: UIView {
    
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
            UIView.animate(withDuration: 0.3) {
                self.userImageView.layer.borderWidth = self.shouldShowBadge ? 3 : 0
                self.badgeImageView.isHidden = self.shouldShowBadge == false
                self.rankRibbonImageView.isHidden = self.shouldShowBadge == false
            }
        }
    }
    
    public var userImage: UIImage? {
        return userImageView.image
    }
    
    public private(set) var badgeImageView = UIImageView()
    public private(set) var userImageView = UIImageView()
    public private(set) var rankRibbonImageView = UIImageView()
    private let rankLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        configureUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.layer.cornerRadius = bounds.height / 2
    }
    
    private func configureAppearanceBasedOnRank() {
        rankLabel.text = String(rank)
        rankLabel.textColor = .white
        
        switch rank {
        case 0:
            rankRibbonImageView.image = nil
            rankLabel.isHidden = true
            
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
private extension BadgedProfileImageView {
    func configureUI() {
        configureUserImageView()
        configureRankRibbonImageView()
        configureBadgeImageView()
        configureBadgeImageView()
        configureRankLabel()
    }
    
    func configureUserImageView() {
        userImageView.contentMode = .scaleAspectFill
//      userImageView.layer.borderColor = UIColor.carrot.cgColor
//      userImageView.layer.cornerRadius = 13
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = .clear
        
        addSubview(userImageView)
        userImageView.anchors.edges.pin()
    }
    
    func configureRankRibbonImageView() {
        rankRibbonImageView.isHidden = true
        rankRibbonImageView.contentMode = .scaleAspectFit
        
        addSubview(rankRibbonImageView)
        rankRibbonImageView.anchors.width.equal(anchors.width * 0.27)
        rankRibbonImageView.anchors.height.equal(anchors.height * 0.35)
        rankRibbonImageView.anchors.trailing.equal(userImageView.anchors.trailing, constant: 0)
        rankRibbonImageView.anchors.centerY.equal(userImageView.anchors.bottom, constant: -10)
    }
    
    func configureBadgeImageView() {
        badgeImageView.isHidden = true
        badgeImageView.contentMode = .scaleAspectFill
        
        addSubview(badgeImageView)
        badgeImageView.anchors.width.equal(anchors.width * 0.55)
        badgeImageView.anchors.height.equal(anchors.height * 0.577)
        badgeImageView.anchors.leading.equal(userImageView.anchors.leading, constant: -15)
        badgeImageView.anchors.top.pin(inset: -15)
    }
    
    func configureRankLabel() {
        rankLabel.font = .roboto(.medium, size: 11)
        
        rankRibbonImageView.addSubview(rankLabel)
        rankLabel.anchors.centerX.align()
        rankLabel.anchors.bottom.equal(rankRibbonImageView.anchors.centerY, constant: 3)
    }
}
