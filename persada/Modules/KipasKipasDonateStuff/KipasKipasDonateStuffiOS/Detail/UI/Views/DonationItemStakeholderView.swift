import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

final class DonationItemStakeholderView: UIView {
    
    private let stackRightContent = UIStackView()
    
    let imageView = UIImageView()
    let roleLabel = UILabel()
    let nameLabel = UILabel()
    
    var onReuse: EmptyClosure?
    
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
        imageView.layer.cornerRadius = 32 / 2
    }
}

// MARK: UI
private extension DonationItemStakeholderView {
    func configureUI() {
        backgroundColor = .white
        
        configureImageView()
        configureStackRightContent()
    }
    
    func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .softPeach
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        
        addSubview(imageView)
        imageView.anchors.width.equal(32)
        imageView.anchors.height.equal(32)
        imageView.anchors.leading.pin(inset: 16)
        imageView.anchors.centerY.align()
    }
    
    func configureStackRightContent() {
        stackRightContent.axis = .vertical
        stackRightContent.spacing = 4
        stackRightContent.distribution = .equalCentering
        
        addSubview(stackRightContent)
        stackRightContent.anchors.leading.equal(imageView.anchors.trailing, constant: 8)
        stackRightContent.anchors.edges.pin(axis: .vertical)
        stackRightContent.anchors.trailing.pin(inset: 16)
        
        configureRoleLabel()
        configureNameLabel()
    }
    
    func configureRoleLabel() {
        roleLabel.text = .placeholderWithSpaces()
        roleLabel.textColor = .boulder
        roleLabel.font = .roboto(.medium, size: 12)
        
        stackRightContent.addArrangedSubview(roleLabel)
    }
    
    func configureNameLabel() {
        nameLabel.text = .placeholderWithSpaces()
        nameLabel.textColor = .gravel
        nameLabel.font = .roboto(.medium, size: 12)
        nameLabel.numberOfLines = 2
        
        stackRightContent.addArrangedSubview(nameLabel)
    }
}
