import UIKit
import KipasKipasShared

final class DonationRankCell: UICollectionViewCell {
    
    private(set) var imageView = BadgedImageView()
    private let stackLabel = UIStackView()
    
    private(set) var nameLabel = UILabel()
    private(set) var usernameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: UI
private extension DonationRankCell {
    func configureUI() {
        configureUserImageView()
        configureStackLabel()
    }
    
    func configureUserImageView() {
        imageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(imageView)
        imageView.anchors.leading.pin()
        imageView.anchors.height.equal(contentView.anchors.height)
        imageView.anchors.width.equal(imageView.anchors.height)
    }
    
    func configureStackLabel() {
        stackLabel.axis = .vertical
        stackLabel.spacing = 4
        
        contentView.addSubview(stackLabel)
        stackLabel.anchors.centerY.align()
        stackLabel.anchors.trailing.equal(contentView.anchors.trailing, constant: 12)
        stackLabel.anchors.leading.spacing(15, to: imageView.anchors.trailing)
        
        configureUserNameLabel()
        configureUsernameLabel()
    }
    
    func configureUserNameLabel() {
        nameLabel.font = .rye(.regular, size: 14)
        nameLabel.textColor = .white
        
        stackLabel.addArrangedSubview(nameLabel)
    }
    
    func configureUsernameLabel() {
        usernameLabel.font = .roboto(.regular, size: 11)
        usernameLabel.textColor = .ashGrey
        
        stackLabel.addArrangedSubview(usernameLabel)
    }
}
