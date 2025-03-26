import UIKit
import KipasKipasShared

final class DonationHistoryCell: UICollectionViewCell {
    
    private let lineView = UIView()
    
    private let contentRightStack = UIStackView()
    private let contentLeftStack = UIStackView()
    
    /// Left Content
    private(set) var timestampLabel = UILabel()
    private(set) var donorNameLabel = UILabel()
        
    /// Right Content
    private(set) var amountLabel = UILabel()
    private(set) var feeLabel = UILabel()
    
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
private extension DonationHistoryCell {
    func configureUI() {
        configureContentRightStack()
        configureContentLeftStack()
        configureLineView()
    }
    
    func configureContentLeftStack() {
        contentLeftStack.spacing = 8
        
        contentView.addSubview(contentLeftStack)
        contentLeftStack.anchors.leading.pin()
        contentLeftStack.anchors.centerY.align()
        
        configureTimestampLabel()
        configureDonorNameLabel()
    }
    
    func configureContentRightStack() {
        contentRightStack.axis = .vertical
        contentRightStack.spacing = 2
        
        contentView.addSubview(contentRightStack)
        contentRightStack.anchors.trailing.pin()
        contentRightStack.anchors.centerY.align()
        
        configureAmountLabel()
        configureFeeLabel()
    }
    
    func configureTimestampLabel() {
        timestampLabel.font = .roboto(.medium, size: 13)
        timestampLabel.textColor = .boulder
        
        contentLeftStack.addArrangedSubview(timestampLabel)
    }
    
    func configureDonorNameLabel() {
        donorNameLabel.font = .roboto(.regular, size: 13)
        donorNameLabel.textColor = .boulder
        
        contentLeftStack.addArrangedSubview(donorNameLabel)
        donorNameLabel.anchors.width.lessThanOrEqual(125)
    }
    
    func configureAmountLabel() {
        amountLabel.font = .roboto(.medium, size: 13)
        amountLabel.textColor = .azure
        amountLabel.textAlignment = .right
        
        contentRightStack.addArrangedSubview(amountLabel)
    }
    
    func configureFeeLabel() {
        feeLabel.font = .roboto(.medium, size: 9)
        feeLabel.textColor = .brightRed
        feeLabel.textAlignment = .right
        
        contentRightStack.addArrangedSubview(feeLabel)
    }
    
    func configureLineView() {
        lineView.backgroundColor = .softPeach
        
        contentView.addSubview(lineView)
        lineView.anchors.height.equal(1)
        lineView.anchors.bottom.pin()
        lineView.anchors.edges.pin(axis: .horizontal)
    }
}
