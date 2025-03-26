import UIKit
import KipasKipasShared

final class KKReportCell: UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    private(set) var reasonLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    func select() {
        contentView.backgroundColor = .water
        reasonLabel.textColor = .azure

    }
    
    func deselect() {
        contentView.backgroundColor = .white
        reasonLabel.textColor = .gravel
    }
}

// MARK: UI
private extension KKReportCell {
    func configureUI() {
        contentView.layer.cornerRadius = 4
        
        configureReasonLabel()
    }
    
    func configureReasonLabel() {
        reasonLabel.textAlignment = .left
        reasonLabel.numberOfLines = 0
        reasonLabel.font = .airbnb(.bold, size: 14)
        reasonLabel.textColor = .gravel
        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(reasonLabel)
        NSLayoutConstraint.activate([
            reasonLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            reasonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            reasonLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            reasonLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
