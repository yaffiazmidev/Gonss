import UIKit
import KipasKipasShared

final class GenderCell: UICollectionViewCell {
    
    private let containerView = UIView()
    private let stackView = UIStackView()
    
    private(set) var genderImageView = UIImageView()
    private(set) var genderLabel = UILabel()
    
    var isCellSelected: Bool = false {
        didSet {
            isSelected = isCellSelected
            setBorder()
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
    
    // MARK: UI
    private func configureUI() {
        configureContainerView()
        configureStackView()
    }
    
    private func configureContainerView() {
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = .snowDrift
        containerView.clipsToBounds = true
        
        contentView.addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    private func configureStackView() {
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .center
        
        containerView.addSubview(stackView)
        stackView.anchors.center.align()
        stackView.anchors.edges.pin(insets: 16, axis: .horizontal)
        
        configureGenderImageView()
        configureGenderLabel()
    }
    
    private func configureGenderImageView() {
        genderImageView.contentMode = .scaleAspectFill
        genderImageView.tintColor = .boulder
        
        stackView.addArrangedSubview(genderImageView)
    }
    
    private func configureGenderLabel() {
        genderLabel.font = .roboto(.regular, size: 10)
        genderLabel.textColor = .boulder
        genderLabel.numberOfLines = 2
        genderLabel.textAlignment = .center
        
        stackView.addArrangedSubview(genderLabel)
    }
    
    private func setBorder() {
        if isCellSelected {
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.watermelon.cgColor
            genderImageView.tintColor = .watermelon
            genderLabel.textColor = .watermelon
        } else {
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.clear.cgColor
            genderImageView.tintColor = .boulder
            genderLabel.textColor = .boulder
        }
    }
}
