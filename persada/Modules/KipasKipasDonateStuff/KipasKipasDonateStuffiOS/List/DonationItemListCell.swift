import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

final class DonationItemListCell: UITableViewCell {
    
    private let stackContainer = UIStackView()
    
    let itemImageView = UIImageView()
    
    private let itemCheckmarkContainer = UIView()
    private let itemCheckmarkImageView = UIImageView()
    private let stackRightContent = UIStackView()
    
    private let stackItemNeeded = UIStackView()
    private let itemNeededLabel = UILabel()
    private let itemNameLabel = UILabel()
    private let itemPriceLabel = UILabel()
    private let itemAmountNeededLabel = UILabel()
    private let itemCollectedProgressView = AnimatedProgressView()
    private let stackProgressView = UIStackView()
    
    var onReuse: EmptyClosure?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        itemCheckmarkContainer.layer.cornerRadius = 40 / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }
    
    func configure(
        with viewModel: DonationItemViewModel,
        role: DonationItemRole
    ) {
        itemNameLabel.text = viewModel.itemName
        itemPriceLabel.text = viewModel.itemPriceDesc
        
        setLayoutType(role)
        setProgress(viewModel)
        setItemAmount(viewModel)
    }
    
    private func setLayoutType(_ role: DonationItemRole) {
        let isInitiator = role == .initiator
        
        itemPriceLabel.isHidden = isInitiator
        itemNeededLabel.text = isInitiator ? "Terkumpul" : "Kebutuhan"
    }
    
    private func setProgress(_ viewModel: DonationItemViewModel) {
        let isCompleted = viewModel.collectionCompleted
        
        itemCheckmarkImageView.image = isCompleted ? .iconCircleCheckGreen : nil
        itemCheckmarkContainer.isHidden = isCompleted == false
        itemPriceLabel.textColor = isCompleted ? .gravel : .watermelon
        
        let progressColor: UIColor = isCompleted ? .success : .watermelon
        itemCollectedProgressView.startColor = progressColor
        itemCollectedProgressView.endColor = progressColor
        itemCollectedProgressView.setProgress(viewModel.collectionProgress, animated: false)
    }
    
    private func setItemAmount(_ viewModel: DonationItemViewModel) {
        let attributedText = NSMutableAttributedString(string: viewModel.itemAmountDesc)
        
        if let range = viewModel.itemAmountHighlightedRange {
            let color: UIColor = viewModel.collectionCompleted ? .success : .watermelon
            attributedText.addAttribute(.foregroundColor, value: color, range: range)
        }
        
        itemAmountNeededLabel.attributedText = attributedText
    }
}

// MARK: UI
private extension DonationItemListCell {
    func configureUI() {
        contentView.backgroundColor = .white
        
        configureStackContainer()
        configureItemImageView()
        configureStackRightContent()
    }
    
    func configureStackContainer() {
        stackContainer.spacing = 8
        
        addSubview(stackContainer)
        stackContainer.anchors.top.pin(inset: 16)
        stackContainer.anchors.edges.pin(insets: 16, axis: .horizontal)
        stackContainer.anchors.bottom.pin()
    }
    
    func configureItemImageView() {
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.backgroundColor = .softPeach
        itemImageView.layer.cornerRadius = 6
        itemImageView.clipsToBounds = true
        
        stackContainer.addArrangedSubview(itemImageView)
        itemImageView.anchors.width.equal(64)
        itemImageView.anchors.height.equal(64)
        
        configureItemCheckmarkImageView()
    }
    
    func configureItemCheckmarkImageView() {
        itemCheckmarkContainer.backgroundColor = .white
        itemCheckmarkContainer.isHidden = true
        
        itemCheckmarkImageView.image = .iconCircleCheckGreen
        itemCheckmarkImageView.backgroundColor = .clear
        itemCheckmarkImageView.contentMode = .scaleAspectFill
        
        itemImageView.addSubview(itemCheckmarkContainer)
        itemCheckmarkContainer.anchors.center.align()
        itemCheckmarkContainer.anchors.width.equal(40)
        itemCheckmarkContainer.anchors.height.equal(40)
        
        itemCheckmarkContainer.addSubview(itemCheckmarkImageView)
        itemCheckmarkImageView.anchors.edges.pin(insets: 3)
    }
    
    func configureStackRightContent() {
        stackRightContent.axis = .vertical
        stackRightContent.distribution = .equalSpacing
        stackContainer.addArrangedSubview(stackRightContent)
        
        configureItemNameLabel()
        configureItemPriceLabel()
        configureStackProgressView()
    }
    
    func configureItemNameLabel() {
        itemNameLabel.text = .placeholderWithSpaces()
        itemNameLabel.textColor = .night
        itemNameLabel.font = .roboto(.medium, size: 12)
        
        stackRightContent.addArrangedSubview(itemNameLabel)
    }
    
    func configureItemPriceLabel() {
        itemPriceLabel.text = .placeholderWithSpaces()
        itemPriceLabel.textColor = .watermelon
        itemPriceLabel.font = .roboto(.bold, size: 16)
        
        stackRightContent.addArrangedSubview(itemPriceLabel)
    }
    
    func configureStackProgressView() {
        stackProgressView.axis = .vertical
        stackProgressView.spacing = 5
        
        stackRightContent.addArrangedSubview(stackProgressView)
        
        configureStackItemNeeded()
        configureItemCollectedProgressView()
    }
    
    func configureStackItemNeeded() {
        stackItemNeeded.distribution = .equalCentering
        stackProgressView.addArrangedSubview(stackItemNeeded)
        
        configureItemNeededLabel()
        configureItemAmountNeedLabel()
    }
    
    func configureItemNeededLabel() {
        itemNeededLabel.text = .placeholderWithSpaces(count: 15)
        itemNeededLabel.textColor = .gravel
        itemNeededLabel.font = .roboto(.regular, size: 11)
        
        stackItemNeeded.addArrangedSubview(itemNeededLabel)
    }
    
    func configureItemAmountNeedLabel() {
        itemAmountNeededLabel.text = .placeholderWithSpaces(count: 15)
        itemAmountNeededLabel.textColor = .gravel
        itemAmountNeededLabel.font = .roboto(.bold, size: 12)
        
        stackItemNeeded.addArrangedSubview(itemAmountNeededLabel)
    }
    
    func configureItemCollectedProgressView() {
        itemCollectedProgressView.grooveColor = .softPeach
        
        stackProgressView.addArrangedSubview(itemCollectedProgressView)
        itemCollectedProgressView.anchors.height.equal(3)
    }
}
