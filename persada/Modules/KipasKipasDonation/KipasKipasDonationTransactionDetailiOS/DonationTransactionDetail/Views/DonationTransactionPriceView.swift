import UIKit
import KipasKipasShared
import Kingfisher

public final class DonationTransactionPriceView: UIView {
    
    private(set) lazy var containerView = UIView()
    private(set) lazy var titleStack = UIStackView()
    private(set) lazy var nameStack = UIStackView()
    private(set) lazy var photoStack = UIStackView()
    private(set) lazy var donationStack = UIStackView()
    private(set) lazy var donationContainer = UIView()
    private(set) lazy var donationTotalLabel = UILabel()
    private(set) lazy var donationAllStack = UIStackView()
    private(set) lazy var donationAllLabel = UILabel()
    private(set) lazy var donationRightIcon = UIImageView()
    
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var priceLabel = UILabel()
    private(set) lazy var nameLabel = UILabel()
    private(set) lazy var photoImageView = UIImageView()
    
    var clickDonations: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        UIFont.loadCustomFonts
        configureContainerView()
    }
    
    private func configureContainerView() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.anchors.edges.pin()
        containerView.backgroundColor = .white
        containerView.accessibilityIdentifier = "containerView"
        
        configureTitleStack()
    }
    
    private func configureTitleStack() {
        containerView.addSubview(titleStack)
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .vertical
        titleStack.spacing = 8
        titleStack.distribution = .fill
        titleStack.accessibilityIdentifier = "titleStack"
        titleStack.anchors.top.equal(containerView.anchors.top, constant: 12)
        titleStack.anchors.leading.equal(containerView.anchors.leading, constant: 12)
        titleStack.anchors.trailing.equal(containerView.anchors.trailing, constant: -12)
        titleStack.anchors.bottom.equal(containerView.anchors.bottom, constant: -12)
        
        configureTitleLabel()
        configurePhotoStack()
        configureDonationStack()
    }
    
    private func configureTitleLabel() {
        titleStack.addArrangedSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .placeholder
        titleLabel.textAlignment = .left
        titleLabel.font = .roboto(.regular, size: 14)
        titleLabel.accessibilityIdentifier = "titleLabel"
        titleLabel.anchors.height.equal(20)
    }
    
    private func configurePhotoStack() {
        titleStack.addArrangedSubview(photoStack)
        photoStack.translatesAutoresizingMaskIntoConstraints = false
        photoStack.axis = .horizontal
        photoStack.distribution = .fill
        photoStack.accessibilityIdentifier = "photoStack"
        photoStack.spacing = 10
        
        configurePhotoImageView()
        configureNameStack()
        configureDonationContainer()
    }
    
    private func configurePhotoImageView() {
        photoStack.addArrangedSubview(photoImageView)
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.layer.cornerRadius = 4.8
        photoImageView.layer.masksToBounds = true
        photoImageView.accessibilityIdentifier = "photoImageView"
        photoImageView.anchors.width.equal(50)
    }
    
    private func configureNameStack() {
        photoStack.addArrangedSubview(nameStack)
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        nameStack.backgroundColor = .clear
        nameStack.axis = .vertical
        nameStack.spacing = 4
        nameStack.distribution = .fill
        nameStack.accessibilityIdentifier = "nameStack"
        
        configureNameLabel()
        configurePriceLabel()
    }
    
    private func configureNameLabel() {
        nameStack.addArrangedSubview(nameLabel)
        nameLabel.textColor = .black
        nameLabel.accessibilityIdentifier = "nameLabel"
        nameLabel.textAlignment = .left
        nameLabel.font = .roboto(.regular, size: 14)
    }
    
    private func configurePriceLabel() {
        nameStack.addArrangedSubview(priceLabel)
        priceLabel.textColor = .black
        priceLabel.textAlignment = .left
        priceLabel.accessibilityIdentifier = "priceLabel"
        priceLabel.font = .roboto(.bold, size: 16)
    }
    
    private func configureDonationContainer() {
        titleStack.addArrangedSubview(donationContainer)
        donationContainer.translatesAutoresizingMaskIntoConstraints = false
        donationContainer.anchors.height.equal(35)
        donationContainer.isHidden = false
        donationContainer.backgroundColor = .secondaryLowTint
        donationContainer.layer.cornerRadius = 8
        donationContainer.accessibilityIdentifier = "donationContainer"
        donationContainer.isHidden = true
        configureDonationStack()
    }
    
    private func configureDonationStack() {
        donationContainer.addSubview(donationStack)
        donationStack.translatesAutoresizingMaskIntoConstraints = false
        donationStack.axis = .horizontal
        donationStack.distribution = .fillEqually
        donationStack.alignment = .fill
        donationStack.accessibilityIdentifier = "donationStack"
        donationStack.anchors.leading.equal(donationContainer.anchors.leading, constant: 12)
        donationStack.anchors.trailing.equal(donationContainer.anchors.trailing, constant: -12)
        donationStack.anchors.top.equal(donationContainer.anchors.top)
        donationStack.anchors.bottom.equal(donationContainer.anchors.bottom)
        
        configureDonationTotalLabel()
        configureDonationAllStack()
        
        donationStack.onTap { [weak self] in
            guard let self = self else { return }
            
            clickDonations?()
        }
    }
    
    private func configureDonationTotalLabel() {
        donationStack.addArrangedSubview(donationTotalLabel)
        donationTotalLabel.textColor = .secondary
        donationTotalLabel.textAlignment = .left
        donationTotalLabel.accessibilityIdentifier = "donationTotalLabel"
        donationTotalLabel.font = .roboto(.medium, size: 12)
        donationTotalLabel.text = "+ 4 donasi"
    }
    
    private func configureDonationAllStack() {
        donationStack.addArrangedSubview(donationAllStack)
        donationAllStack.translatesAutoresizingMaskIntoConstraints = false
        donationAllStack.axis = .horizontal
        donationAllStack.distribution = .fill
        donationAllStack.alignment = .fill
        donationAllStack.isUserInteractionEnabled = true
        donationAllStack.accessibilityIdentifier = "donationAllStack"
        
        configureDonationAllLabel()
        configureDonationRightIcon()
    }
    
    private func configureDonationAllLabel() {
        donationAllStack.addArrangedSubview(donationAllLabel)
        donationAllLabel.textColor = .secondary
        donationAllLabel.textAlignment = .right
        donationAllLabel.font = .roboto(.medium, size: 12)
        donationAllLabel.text = "Lihat Semua"
        donationAllLabel.accessibilityIdentifier = "donationAllLabel"
    }
    
    private func configureDonationRightIcon() {
        donationAllStack.addArrangedSubview(donationRightIcon)
        donationRightIcon.translatesAutoresizingMaskIntoConstraints = false
        donationRightIcon.contentMode = .scaleAspectFit
        donationRightIcon.anchors.width.equal(15)
        donationRightIcon.accessibilityIdentifier = "donationRightIcon"
        donationRightIcon.anchors.trailing.equal(donationAllStack.anchors.trailing)
        donationRightIcon.image = .iconChevronRightOutlineBlack?.withTintColor(.secondary)
    }
    
    public func configure(title: String, name: String, price: String, imageURL: String) {
        titleLabel.text = title
        nameLabel.text = name
        priceLabel.text = price
        
        guard let url = URL(string: imageURL) else { return }
        photoImageView.kf.setImage(with: url, options: [.forceRefresh])
    }
    
    public func configureDonation(count: Int) {
        DispatchQueue.main.async {
            self.donationContainer.isHidden = count <= 1
            self.donationTotalLabel.text = "+ \(count) donasi"
        }
    }
}
