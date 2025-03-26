import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

final class DonationItemDetailInfoCell: UICollectionViewCell {
    
    private let stackContent = UIStackView()
    private let stackInfo = UIStackView()
    
    private let stackItemNeeded = UIStackView()
    private let itemNeededLabel = UILabel()
    private let itemNameLabel = UILabel()
    private let itemPriceLabel = UILabel()
    private let itemAmountNeededLabel = UILabel()
    private let itemCollectedProgressView = AnimatedProgressView()
    private let stackProgressView = UIStackView()
    
    private let completedView = DonationItemCompletedView()
    
    var onReuse: EmptyClosure?
    
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
    
    func configure(with viewModel: DonationItemViewModel, role: DonationItemRole) {
        itemNameLabel.text = viewModel.itemName
        itemPriceLabel.text = viewModel.itemPriceDesc
        itemPriceLabel.isHidden = role == .initiator
        itemNeededLabel.text = "Kebutuhan"
        
        setProgress(viewModel)
        setItemAmount(viewModel)
    }
    
    private func setProgress(_ viewModel: DonationItemViewModel) {
        let isCompleted = viewModel.collectionCompleted
        
        contentView.backgroundColor = isCompleted ? .greenWhite : .white
        completedView.isHidden = !isCompleted
        stackInfo.isHidden = isCompleted
        stackProgressView.isHidden = isCompleted
        
        itemCollectedProgressView.setProgress(viewModel.collectionProgress, animated: false)
    }
    
    private func setItemAmount(_ viewModel: DonationItemViewModel) {
        let attributedText = NSMutableAttributedString(string: viewModel.itemAmountDesc)
        
        if let range = viewModel.itemAmountHighlightedRange {
            attributedText.addAttribute(.foregroundColor, value: UIColor.watermelon, range: range)
        }
        
        itemAmountNeededLabel.attributedText = attributedText
    }
}

// MARK: UI
private extension DonationItemDetailInfoCell {
    func configureUI() {
        contentView.backgroundColor = .white
        configureStackContent()
    }
    
    func configureStackContent() {
        stackContent.axis = .vertical
        stackContent.spacing = 20
        
        addSubview(stackContent)
        stackContent.anchors.top.pin(inset: 12)
        stackContent.anchors.edges.pin(insets: 16, axis: .horizontal)
        stackContent.anchors.bottom.pin(inset: 8)
        
        configureCompletedView()
        configureStackInfo()
        configureStackProgressView()
    }
    
    func configureCompletedView() {
        completedView.isHidden = true
        stackContent.addArrangedSubview(completedView)
    }
    
    func configureStackInfo() {
        stackInfo.axis = .vertical
        stackInfo.spacing = 8
        
        stackContent.addArrangedSubview(stackInfo)
        
        configureItemNameLabel()
        configureItemPriceLabel()
    }
    
    func configureItemNameLabel() {
        itemNameLabel.text = .placeholderWithSpaces()
        itemNameLabel.textColor = .night
        itemNameLabel.font = .roboto(.medium, size: 16)
        itemNameLabel.numberOfLines = 2
        itemNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        stackInfo.addArrangedSubview(itemNameLabel)
    }
    
    func configureItemPriceLabel() {
        itemPriceLabel.text = .placeholderWithSpaces()
        itemPriceLabel.textColor = .watermelon
        itemPriceLabel.font = .roboto(.bold, size: 18)
        
        stackInfo.addArrangedSubview(itemPriceLabel)
    }
    
    func configureStackProgressView() {
        stackProgressView.axis = .vertical
        stackProgressView.spacing = 5
        
        stackContent.addArrangedSubview(stackProgressView)
        
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
        itemNeededLabel.text = .placeholderWithSpaces()
        itemNeededLabel.textColor = .gravel
        itemNeededLabel.font = .roboto(.regular, size: 11)
        
        stackItemNeeded.addArrangedSubview(itemNeededLabel)
    }
    
    func configureItemAmountNeedLabel() {
        itemAmountNeededLabel.text = .placeholderWithSpaces()
        itemAmountNeededLabel.textColor = .gravel
        itemAmountNeededLabel.font = .roboto(.bold, size: 12)
        
        stackItemNeeded.addArrangedSubview(itemAmountNeededLabel)
    }
    
    func configureItemCollectedProgressView() {
        itemCollectedProgressView.grooveColor = .softPeach
        itemCollectedProgressView.startColor = .watermelon
        itemCollectedProgressView.endColor = .watermelon
        
        stackProgressView.addArrangedSubview(itemCollectedProgressView)
        itemCollectedProgressView.anchors.height.equal(4)
    }
}

extension String {
    static func placeholderWithSpaces(count: Int = 30) -> String {
        return String(repeating: " ", count: count)
    }
}
