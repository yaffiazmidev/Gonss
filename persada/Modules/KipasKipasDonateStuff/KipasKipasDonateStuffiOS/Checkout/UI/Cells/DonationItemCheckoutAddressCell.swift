import UIKit
import KipasKipasShared

final class DonationItemCheckoutAddressCell: UICollectionViewCell {
    
    private let stackLabel = UIStackView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    
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

    // MARK: API
    func setAddress(_ address: String) {
        addressLabel.text = address
    }
}

// MARK: UI
private extension DonationItemCheckoutAddressCell {
    func configureUI() {
        contentView.backgroundColor = .white

        configureStackLabel()
        configureTitleLabel()
        configureDescriptionLabel()
    }
    
    func configureStackLabel() {
        stackLabel.axis = .vertical
        stackLabel.spacing = 8
        stackLabel.alignment = .top
        
        addSubview(stackLabel)
        stackLabel.anchors.edges.pin(insets: 8, axis: .vertical)
        stackLabel.anchors.edges.pin(insets: 16, axis: .horizontal)
    }
    
    func configureTitleLabel() {
        titleLabel.text = "Dikirim ke Alamat Yayasan"
        titleLabel.font = .roboto(.medium, size: 12)
        titleLabel.textColor = .boulder
        
        stackLabel.addArrangedSubview(titleLabel)
    }
    
    func configureDescriptionLabel() {
        addressLabel.text = .placeholderWithSpaces(count: 100)
        addressLabel.font = .roboto(.medium, size: 14)
        addressLabel.textColor = .gravel
        addressLabel.numberOfLines = 0
        
        stackLabel.addArrangedSubview(addressLabel)
    }
}
