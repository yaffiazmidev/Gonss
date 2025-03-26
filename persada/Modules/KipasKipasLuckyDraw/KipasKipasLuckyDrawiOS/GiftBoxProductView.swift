import UIKit
import KipasKipasShared

final class GiftBoxProductView: UIView {
    
    private let stackContainer = UIStackView()
    private(set) var productImageView = UIImageView()
    private let stackRightContent = UIStackView()
    
    private let stackLabelVertical = UIStackView()
    private(set) var productNameLabel = UILabel()
    private(set) var participantLabel = UILabel()
    
    private let stackLabelHorizontal = UIStackView()
    private(set) var priceLabel = UILabel()
    private(set) var discountedPriceLabel = UILabel()
    
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
private extension GiftBoxProductView {
    func configureUI() {
        backgroundColor = .clear
        
        configureStackContainer()
        configureProductImageView()
        configureStackRightContent()
    }
    
    func configureStackContainer() {
        stackContainer.spacing = 8
        
        addSubview(stackContainer)
        stackContainer.anchors.edges.pin()
    }
    
    func configureProductImageView() {
        productImageView.contentMode = .scaleAspectFill
        productImageView.backgroundColor = .softPeach
        productImageView.layer.cornerRadius = 6
        productImageView.layer.borderWidth = 1
        productImageView.layer.borderColor = UIColor.paleSalmon.cgColor
        productImageView.clipsToBounds = true
        
        stackContainer.addArrangedSubview(productImageView)
        
        productImageView.anchors.width.equal(84)
        productImageView.anchors.height.equal(84)
    }
    
    func configureStackRightContent() {
        stackRightContent.axis = .vertical
        stackRightContent.distribution = .equalSpacing
        stackContainer.addArrangedSubview(stackRightContent)
        
        configureStackLabelVertical()
        configureStackLabelHorizontal()
    }
    
    func configureStackLabelVertical() {
        stackLabelVertical.axis = .vertical
        stackLabelVertical.spacing = 5
        
        stackRightContent.addArrangedSubview(stackLabelVertical)
        
        configureProductNameLabel()
        configureParticipantLabel()
    }
    
    func configureProductNameLabel() {
        productNameLabel.font = .roboto(.medium, size: 16)
        productNameLabel.textColor = .paleCarmine
        
        stackLabelVertical.addArrangedSubview(productNameLabel)
    }
    
    func configureParticipantLabel() {
        participantLabel.text = "Telah ada 1000 orang yang berpartisipasi"
        participantLabel.font = .roboto(.light, size: 11)
        participantLabel.textColor = UIColor.redOxide.withAlphaComponent(0.5)
        
        stackLabelVertical.addArrangedSubview(participantLabel)
    }
    
    func configureStackLabelHorizontal() {
        stackLabelHorizontal.spacing = 3
        
        stackRightContent.addArrangedSubview(stackLabelHorizontal)
        
        configureDiscountedPriceLabel()
        configurePriceLabel()
        stackLabelHorizontal.addArrangedSubview(invisibleView())
    }
    
    func configureDiscountedPriceLabel() {
        discountedPriceLabel.text = "Rp0"
        discountedPriceLabel.font = .roboto(.medium, size: 15)
        discountedPriceLabel.textColor = .paleCarmine
        
        stackLabelHorizontal.addArrangedSubview(discountedPriceLabel)
    }
    
    func configurePriceLabel() {
        stackLabelHorizontal.addArrangedSubview(priceLabel)
    }
}

