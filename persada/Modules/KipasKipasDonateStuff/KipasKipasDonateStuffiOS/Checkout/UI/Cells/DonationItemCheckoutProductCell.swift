import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemCheckoutProductCell: UICollectionViewCell {
    
    private let stackContainer = UIStackView()
    private let stackContent = UIStackView()
    private let stackInfo = UIStackView()
    
    private let itemNameLabel = UILabel()
    private let itemPriceLabel = UILabel()
    
    let itemImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    func configure(with viewModel: DonationItemViewModel) {
        itemNameLabel.text = viewModel.itemName
        itemPriceLabel.text = viewModel.itemPriceDesc
    }
}

// MARK: UI
private extension DonationItemCheckoutProductCell {
    func configureUI() {
        contentView.backgroundColor = .white
        
        configureStackContainer()
        configureItemImageView()
        configureStackContent()
    }
    
    func configureStackContainer() {
        stackContainer.spacing = 8
        stackContainer.alignment = .top
        
        addSubview(stackContainer)
        stackContainer.anchors.edges.pin(insets: 12, axis: .vertical)
        stackContainer.anchors.edges.pin(insets: 16, axis: .horizontal)
    }
    
    func configureStackContent() {
        stackContent.axis = .vertical
        stackContent.spacing = 10
        
        stackContainer.addArrangedSubview(stackContent)
        
        configureStackInfo()
    }
    
    func configureItemImageView() {
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.backgroundColor = .softPeach
        itemImageView.layer.cornerRadius = 4
        itemImageView.clipsToBounds = true
        
        stackContainer.addArrangedSubview(itemImageView)
        itemImageView.anchors.width.equal(50)
        itemImageView.anchors.height.equal(50)
    }
    
    func configureStackInfo() {
        stackInfo.axis = .vertical
        stackInfo.spacing = 4
        
        stackContent.addArrangedSubview(stackInfo)
        
        configureItemNameLabel()
        configureItemPriceLabel()
    }
    
    func configureItemNameLabel() {
        itemNameLabel.text = .placeholderWithSpaces()
        itemNameLabel.textColor = .night
        itemNameLabel.font = .roboto(.medium, size: 14)
        itemNameLabel.numberOfLines = 2
        itemNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        stackInfo.addArrangedSubview(itemNameLabel)
    }
    
    func configureItemPriceLabel() {
        itemPriceLabel.text = .placeholderWithSpaces()
        itemPriceLabel.textColor = .watermelon
        itemPriceLabel.font = .roboto(.medium, size: 12)
        
        stackInfo.addArrangedSubview(itemPriceLabel)
    }
}
