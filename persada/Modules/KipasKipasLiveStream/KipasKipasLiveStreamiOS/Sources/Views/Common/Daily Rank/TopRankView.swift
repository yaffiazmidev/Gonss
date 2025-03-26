import UIKit
import KipasKipasShared
import KipasKipasLiveStream

final class TopRankView: UIView {
    private let container = UIView()
    private let stack = ScrollContainerView()
    private let stackLabel = UIStackView()
    
    private let backgroundImageView = UIImageView()
    private let userImageView = UIImageView()
    private let nameLabel = UILabel()
    private let verifiedIcon = UIImageView()
    private let totalLikesLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: API
    func configure(with viewModel: LiveDailyRankViewModel?, rank: Int) {
        if let model = viewModel {
            
            if let image = model.imageURL, !image.isEmpty {
                userImageView.setImage(with: image)
                userImageView.contentMode = .scaleAspectFill
            }
            
            nameLabel.text = model.name
            nameLabel.isHidden = false
            verifiedIcon.isHidden = model.isVerified == false
            totalLikesLabel.text = model.totalLikes
            totalLikesLabel.isHidden = model.totalLikes == "0"
            
        } else {
            verifiedIcon.isHidden = true
            totalLikesLabel.isHidden = true
            nameLabel.isHidden = true
        }
        
        let dimension: CGFloat = rank == 1 ? 58 : 50
        userImageView.anchors.width.equal(dimension)
        userImageView.anchors.height.equal(dimension)
        userImageView.layer.cornerRadius = dimension / 2
        
        switch rank {
        case 1:
            backgroundImageView.image = .backgroundDailyRank1
        case 2:
            backgroundImageView.image = .backgroundDailyRank2
        case 3:
            backgroundImageView.image = .backgroundDailyRank3
        default:
            break
        }
    }
}

private extension TopRankView {
    func configureUI() {
        configureContainer()
    }
    
    func configureContainer() {
        container.backgroundColor = .snowDrift
        
        addSubview(container)
        container.anchors.edges.pin()
        
        configureBackgroundImageView()
        configureStack()
    }
    
    func configureBackgroundImageView() {
        backgroundImageView.contentMode = .topRight
        
        container.addSubview(backgroundImageView)
        backgroundImageView.anchors.edges.pin()
    }
    
    func configureStack() {
        stack.isCentered = true
        stack.alignment = .center
        stack.isScrollEnabled = false
        stack.spacingBetween = 8
        
        container.addSubview(stack)
        stack.anchors.edges.pin(insets: 8, axis: .horizontal)
        stack.anchors.edges.pin(axis: .vertical)
        
        configureUserImageView()
        configureStackLabel()
    }
    
    func configureUserImageView() {
        userImageView.image = .defaultProfileImage
        userImageView.backgroundColor = .whiteSmoke
        userImageView.clipsToBounds = true
        userImageView.contentMode = .center
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor.white.cgColor
        
        stack.addArrangedSubViews(userImageView)
    }
    
    func configureStackLabel() {
        stackLabel.spacing = 2
        stackLabel.alignment = .center
        stackLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        stack.addArrangedSubViews(stackLabel)
        
        configureNameLabel()
        configureVerifiedIcon()
        configureTotalLikesLabel()
    }
    
    func configureNameLabel() {
        nameLabel.font = .roboto(.medium, size: 17)
        nameLabel.textColor = .gravel
        nameLabel.textAlignment = .justified
        
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
        totalLikesLabel.textAlignment = .center
        totalLikesLabel.font = .roboto(.regular, size: 11)
        totalLikesLabel.textColor = .boulder
        
        stack.addArrangedSubViews(totalLikesLabel)
    }
}
