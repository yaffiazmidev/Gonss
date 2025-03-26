import UIKit
import KipasKipasShared

final class DonationItemDetailDescriptionCell: UICollectionViewCell, SkeletonDisplayableStatus {
    
    private let stackLabel = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    var onReuse: EmptyClosure?
    
    var isSkeletonShowing: Bool = false {
        didSet {
            if isSkeletonShowing {
                descriptionLabel.text = .placeholderWithSpaces(count: 100)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }

    // MARK: API
    func setDescription(_ description: String) {
        descriptionLabel.text = description
    }
}

// MARK: UI
private extension DonationItemDetailDescriptionCell {
    func configureUI() {
        contentView.backgroundColor = .white

        configureStackLabel()
        configureTitleLabel()
        configureDescriptionLabel()
    }
    
    func configureStackLabel() {
        stackLabel.axis = .vertical
        stackLabel.spacing = 8
        stackLabel.alignment = .top
        
        addSubview(stackLabel)
        stackLabel.anchors.edges.pin(insets: 8, axis: .vertical)
        stackLabel.anchors.edges.pin(insets: 16, axis: .horizontal)
    }
    
    func configureTitleLabel() {
        titleLabel.text = "Deskripsi"
        titleLabel.font = .roboto(.medium, size: 12)
        titleLabel.textColor = .boulder
        
        stackLabel.addArrangedSubview(titleLabel)
    }
    
    func configureDescriptionLabel() {
        descriptionLabel.text = .placeholderWithSpaces(count: 100)
        descriptionLabel.font = .roboto(.regular, size: 14)
        descriptionLabel.textColor = .gravel
        descriptionLabel.numberOfLines = 0
        
        stackLabel.addArrangedSubview(descriptionLabel)
    }
}
