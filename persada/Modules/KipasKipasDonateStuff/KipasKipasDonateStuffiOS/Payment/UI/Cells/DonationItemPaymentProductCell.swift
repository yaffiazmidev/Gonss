import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemPaymentProductCell: UICollectionViewCell {
    
    private let stackContainer = UIStackView()
    private let stackInfo = UIStackView()
    private let stackPrice = UIStackView()
    
    private let itemNameLabel = UILabel()
    private let itemPriceLabel = UILabel()
    private let itemQuantityLabel = UILabel()
    
    let itemImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    func configure(with viewModel: DonationItemPaymentProductViewModel) {
        itemNameLabel.text = viewModel.productName
        itemPriceLabel.text = viewModel.productPrice.inRupiah()
        itemQuantityLabel.text = "x\(viewModel.productQty)"
    }
}

// MARK: UI
private extension DonationItemPaymentProductCell {
    func configureUI() {
        contentView.backgroundColor = .white
        
        configureStackContainer()
        configureItemImageView()
        configureStackInfo()
    }
    
    func configureStackContainer() {
        stackContainer.spacing = 10
        stackContainer.alignment = .center
        
        addSubview(stackContainer)
        stackContainer.anchors.top.pin(inset: 12)
        stackContainer.anchors.edges.pin(insets: 16, axis: .horizontal)
        stackContainer.anchors.bottom.pin(inset: 12)
    }
    
    func configureItemImageView() {
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.backgroundColor = .softPeach
        itemImageView.layer.cornerRadius = 4
        itemImageView.clipsToBounds = true
        
        stackContainer.addArrangedSubview(itemImageView)
        itemImageView.anchors.width.equal(40)
        itemImageView.anchors.height.equal(40)
    }
    
    func configureStackInfo() {
        stackInfo.axis = .vertical
        stackInfo.spacing = 4
        
        stackContainer.addArrangedSubview(stackInfo)
        
        configureItemNameLabel()
        configureStackPrice()
    }
    
    func configureStackPrice() {
        stackPrice.distribution = .equalCentering
        
        stackInfo.addArrangedSubview(stackPrice)
        
        configureItemPriceLabel()
        configureItemQuantityLabel()
    }
    
    func configureItemNameLabel() {
        itemNameLabel.text = .placeholderWithSpaces()
        itemNameLabel.textColor = .boulder
        itemNameLabel.font = .roboto(.regular, size: 14)
        itemNameLabel.numberOfLines = 2
        
        stackInfo.addArrangedSubview(itemNameLabel)
    }
    
    func configureItemPriceLabel() {
        itemPriceLabel.text = .placeholderWithSpaces()
        itemPriceLabel.textColor = .night
        itemPriceLabel.font = .roboto(.medium, size: 14)
        
        stackPrice.addArrangedSubview(itemPriceLabel)
    }
    
    func configureItemQuantityLabel() {
        itemQuantityLabel.text = .placeholderWithSpaces(count: 5)
        itemQuantityLabel.textColor = .night
        itemQuantityLabel.font = .roboto(.medium, size: 14)
        
        stackPrice.addArrangedSubview(itemQuantityLabel)
    }
}
