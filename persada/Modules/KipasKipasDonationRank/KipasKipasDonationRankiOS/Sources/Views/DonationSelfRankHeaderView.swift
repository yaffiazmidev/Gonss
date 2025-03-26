import UIKit
import KipasKipasShared
import KipasKipasDonationRank
import Kingfisher

private final class SelfRankView: UIView {
    
    private(set) var userImageView = BadgedImageView()
    private let stackLabel = UIStackView()
    private let titleLabel = UILabel()
    
    private let stackRankLabel = UIStackView()
    private(set) var rankLabel = UILabel()
    private(set) var rankIndicatorView = UIImageView()
    
    private(set) var rankDescriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = 10
        clipsToBounds = true
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rankLabel.sizeToFit()
    }
}

// MARK: UI
private extension SelfRankView {
    func configureUI() {
        configureUserImageView()
        configureStackLabel()
    }
    
    func configureUserImageView() {
        userImageView.hideRibbon = true
        
        addSubview(userImageView)
        userImageView.anchors.height.equal(anchors.height * 0.85)
        userImageView.anchors.width.equal(userImageView.anchors.height)
        userImageView.anchors.leading.pin(inset: 6)
        userImageView.anchors.centerY.align()
    }
    
    func configureStackLabel() {
        stackLabel.axis = .vertical
        stackLabel.distribution = .equalSpacing
        
        addSubview(stackLabel)
        stackLabel.anchors.leading.spacing(8, to: userImageView.anchors.trailing)
        stackLabel.anchors.trailing.pin(inset: 14)
        stackLabel.anchors.centerY.align()
        
        configureTitleLabel()
        configureStackRankLabel()
        configureRankDescriptionLabel()
    }
    
    func configureTitleLabel() {
        titleLabel.text = "Ranking Saya"
        titleLabel.font = .roboto(.regular, size: 11)
        titleLabel.textColor = .ashGrey
        
        stackLabel.addArrangedSubview(titleLabel)
    }
    
    func configureStackRankLabel() {
        stackRankLabel.alignment = .center
        stackLabel.addArrangedSubview(stackRankLabel)
    
        configureRankLabel()
        configureRankIndicator()
    }
    
    func configureRankLabel() {
        rankLabel.font = .roboto(.bold, size: 14)
        rankLabel.textColor = .white
        
        stackRankLabel.addArrangedSubview(rankLabel)
    }
    
    func configureRankIndicator() {
        rankIndicatorView.contentMode = .left
        
        let spacer = UIView()
        stackRankLabel.addArrangedSubview(spacer)
        spacer.anchors.width.equal(4).priority = .defaultHigh
        
        stackRankLabel.addArrangedSubview(rankIndicatorView)
        rankIndicatorView.anchors.height.equal(8)
    }
    
    func configureRankDescriptionLabel() {
        rankDescriptionLabel.font = .roboto(.medium, size: 8)
        rankDescriptionLabel.textColor = .gainsboro
        
        stackLabel.addArrangedSubview(rankDescriptionLabel)
    }
}

final class DonationSelfRankHeaderView: UICollectionReusableView {
    
    private let stackContainer = UIStackView()
    private let selfRankView = SelfRankView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .deepPurple
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    func setRank(_ rank: Int) {
        if rank != 0 {
            selfRankView.rankLabel.text = String(rank)
            selfRankView.rankDescriptionLabel.text = ""
            selfRankView.rankDescriptionLabel.isHidden = true
            selfRankView.rankIndicatorView.isHidden = false
        } else {
            selfRankView.rankLabel.text = "Belum mendapat peringkat"
            selfRankView.rankDescriptionLabel.text = "Perlu masuk 100 besar untuk mendapat peringkat"
            selfRankView.rankDescriptionLabel.isHidden = false
            selfRankView.rankIndicatorView.isHidden = true
        }
    }
    
    func setRankStatus(_ status: DonationGlobalRankItem.StatusRank) {
        switch status {
        case .UP:
            selfRankView.rankIndicatorView.image = .rankUpgrade
        case .DOWN:
            selfRankView.rankIndicatorView.image = .rankDowngrade
        case .STAY:
            selfRankView.rankIndicatorView.image = nil
        }
    }
    
    func setProfileImage(_ url: URL?) {
        selfRankView.userImageView.userImageView.kf.setImage(with: url, placeholder: UIImage.emptyProfilePhoto)
    }
    
    func setBadgeImage(_ url: URL?) {
        selfRankView.userImageView.badgeImageView.kf.setImage(with: url)
    }
}

// MARK: UI
private extension DonationSelfRankHeaderView {
    func configureUI() {
        configureStackContainer()
        configureSelfRankView()
    }
    
    func configureStackContainer() {
        stackContainer.axis = .vertical
        
        addSubview(stackContainer)
        stackContainer.anchors.height.equal(72)
        stackContainer.anchors.center.align()
    }
    
    func configureSelfRankView() {
        stackContainer.addArrangedSubview(selfRankView)
    }
}
