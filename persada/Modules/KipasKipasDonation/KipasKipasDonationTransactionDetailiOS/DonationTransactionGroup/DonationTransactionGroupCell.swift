import UIKit
import KipasKipasShared
import Kingfisher

public class DonationTransactionGroupCell: UICollectionViewCell {
    
    private(set) lazy var priceLabel = UILabel()
    private(set) lazy var nameLabel = UILabel()
    private(set) lazy var photoImageView = UIImageView()
    private(set) lazy var photoStack = UIStackView()
    private(set) lazy var nameStack = UIStackView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        UIFont.loadCustomFonts
        layer.cornerRadius = 8
        layer.masksToBounds = true
        backgroundColor = .white
        configurePhotoStack()
    }
    
    private func configurePhotoStack() {
        addSubview(photoStack)
        photoStack.translatesAutoresizingMaskIntoConstraints = false
        photoStack.axis = .horizontal
        photoStack.distribution = .fill
        photoStack.spacing = 10
        photoStack.layer.masksToBounds = true
        photoStack.layer.cornerRadius = 6
        photoStack.anchors.edges.pin(insets: 8)
        
        configurePhotoImageView()
        configureNameStack()
    }
    
    private func configurePhotoImageView() {
        photoStack.addArrangedSubview(photoImageView)
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.layer.masksToBounds = true
        photoImageView.layer.cornerRadius = 4.8
        photoImageView.layer.masksToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.anchors.width.equal(50)
    }
    
    private func configureNameStack() {
        photoStack.addArrangedSubview(nameStack)
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        nameStack.backgroundColor = .clear
        nameStack.axis = .vertical
        nameStack.distribution = .fillProportionally
        nameStack.alignment = .fill
        
        configureNameLabel()
        configurePriceLabel()
    }
    
    private func configureNameLabel() {
        nameStack.addArrangedSubview(nameLabel)
        nameLabel.textColor = .black
        nameLabel.accessibilityIdentifier = "nameLabel"
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines = 2
        nameLabel.font = .roboto(.regular, size: 14)
    }
    
    private func configurePriceLabel() {
        nameStack.addArrangedSubview(priceLabel)
        priceLabel.textColor = .black
        priceLabel.textAlignment = .left
        priceLabel.font = .roboto(.bold, size: 16)
    }
    
    public func configure(name: String, price: String, urlString: String) {
        nameLabel.text = name
        priceLabel.text = price
        guard let url = URL(string: urlString) else { return }
        
        photoImageView.kf.setImage(with: url)
    }
}
