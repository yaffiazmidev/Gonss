import UIKit
import KipasKipasShared

final class DailyRankCell: UICollectionViewCell {
        
    private let stack = UIStackView()
    private let stackLabel = UIStackView()
    
    private(set) var rankLabel = UILabel()
    private(set) var imageView = UIImageView()
    private(set) var nameLabel = UILabel()
    private(set) var verifiedIcon = UIImageView()
    private(set) var totalLikesLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = contentView.frame.size.height / 2
    }
}

// MARK: UI
private extension DailyRankCell {
    func configureUI() {
        configureStack()
        configureStackLabel()
        configureTotalLikesLabel()
    }
    
    func configureStack() {
        stack.spacing = 8
        stack.alignment = .center
        
        contentView.addSubview(stack)
        stack.anchors.leading.pin()
        stack.anchors.centerY.align()
        stack.anchors.height.equal(anchors.height)
        
        configureRankLabel()
        configureUserImageView()
    }
    
    func configureStackLabel() {
        stackLabel.spacing = 8
        stackLabel.alignment = .center
        
        contentView.addSubview(stackLabel)
        stackLabel.anchors.leading.spacing(8, to: stack.anchors.trailing)
        stackLabel.anchors.centerY.align()
        
        
        configureNameLabel()
        configureVerifiedIcon()
    }
    
    func configureRankLabel() {
        rankLabel.font = .roboto(.regular, size: 16)
        rankLabel.textColor = .ashGrey
        rankLabel.textAlignment = .left
        rankLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)
        stack.addArrangedSubview(rankLabel)
        rankLabel.anchors.width.greaterThanOrEqual(20)
    }
    
    func configureUserImageView() {
        imageView.backgroundColor = .whiteSmoke
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = .defaultProfileImage
        
        stack.addArrangedSubview(imageView)
        imageView.anchors.width.equal(anchors.height)
        imageView.anchors.height.equal(anchors.height)
    }
    
    func configureNameLabel() {
        nameLabel.font = .roboto(.medium, size: 16)
        nameLabel.textColor = .gravel
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        stackLabel.addArrangedSubview(nameLabel)
    }
    
    func configureVerifiedIcon() {
        verifiedIcon.image = .iconVerified
        verifiedIcon.contentMode = .scaleAspectFill
        
        stackLabel.addArrangedSubview(verifiedIcon)
        verifiedIcon.anchors.width.equal(14)
        verifiedIcon.anchors.height.equal(14)
    }
    
    func configureTotalLikesLabel() {
        totalLikesLabel.font = .roboto(.regular, size: 11)
        totalLikesLabel.textAlignment = .right
        totalLikesLabel.textColor = .boulder
        
        contentView.addSubview(totalLikesLabel)
        totalLikesLabel.anchors.trailing.pin()
        totalLikesLabel.anchors.centerY.align()
        stackLabel.anchors.trailing.spacing(6, to: totalLikesLabel.anchors.leading)
    }
}
