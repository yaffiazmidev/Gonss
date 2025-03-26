import UIKit
import KipasKipasShared

final class DonationItemCheckoutSummaryCell: UICollectionViewCell {
    private let stackView = UIStackView()
    
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    
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
private extension DonationItemCheckoutSummaryCell {
    func configureUI() {
        contentView.backgroundColor = .white
        configureStackView()
    }
    
    func configureStackView() {
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        
        addSubview(stackView)
        stackView.anchors.top.pin(inset: 6)
        stackView.anchors.edges.pin(insets: 16, axis: .horizontal)
        stackView.anchors.bottom.pin(inset: 6)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailLabel)
    }
}
