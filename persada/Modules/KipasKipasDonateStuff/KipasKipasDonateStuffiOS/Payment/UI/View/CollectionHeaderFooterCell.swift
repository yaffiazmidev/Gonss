import UIKit
import KipasKipasShared

final class CollectionHeaderFooterCell: UICollectionViewCell {
    let headerLabel = UILabel()
    
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
        contentView.backgroundColor = .white
        configureHeaderLabel()
    }
    
    private func configureHeaderLabel() {
        headerLabel.font = .roboto(.medium, size: 14)
        headerLabel.textColor = .night
        
        addSubview(headerLabel)
        headerLabel.anchors.top.pin()
        headerLabel.anchors.edges.pin(insets: 16, axis: .horizontal)
        headerLabel.anchors.centerY.align()
    }
}
