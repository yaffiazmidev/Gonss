import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemPaymentInitiatorCell: UICollectionViewCell {
    
    var onTapInitiatorView: EmptyClosure?
    
    private let stackContainerVertical = UIStackView()
    
    private let tapGesture = UITapGestureRecognizer()
    private let stackInitiatorView = UIStackView()
    private let initiatorNameLabel = UILabel()
    private let arrowView = UIImageView()
    
    private let stackContainerHorizontal = UIStackView()
    private let stackContent = UIStackView()
    private let stackInfo = UIStackView()
    
    private let donationTitleLabel = UILabel()
    
    let initiatorImageView = UIImageView()
    let donationPhotoImageView = UIImageView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initiatorImageView.layer.cornerRadius = initiatorImageView.bounds.height / 2
    }
    
    func configure(with viewModel: DonationItemPaymentInitiatorViewModel) {
        donationTitleLabel.text = viewModel.donationTitle
        initiatorNameLabel.text = viewModel.initiatorName
    }
    
    @objc private func didTapInitiatorView() {
        onTapInitiatorView?()
    }
    
    deinit {
        stackInitiatorView.removeGestureRecognizer(tapGesture)
    }
}

// MARK: UI
private extension DonationItemPaymentInitiatorCell {
    func configureUI() {
        contentView.backgroundColor = .white
        
        configureStackContainerVertical()
        configureStackInitiatorView()
        configureStackContainerHorizontal()
        configureDonationPhotoImageView()
        configureStackContent()
    }
    
    func configureStackContainerVertical() {
        stackContainerVertical.spacing = 16
        stackContainerVertical.axis = .vertical
        
        addSubview(stackContainerVertical)
        stackContainerVertical.anchors.edges.pin(insets: 12, axis: .vertical)
        stackContainerVertical.anchors.edges.pin(insets: 16, axis: .horizontal)
    }
    
    func configureStackInitiatorView() {
        stackInitiatorView.spacing = 8
        stackInitiatorView.alignment = .center
        
        tapGesture.addTarget(self, action: #selector(didTapInitiatorView))
        stackInitiatorView.addGestureRecognizer(tapGesture)
        
        stackContainerVertical.addArrangedSubview(stackInitiatorView)
        configureInitiatorImageView()
        configureInitiatorNameLabel()
        configureArrowView()
    }
    
    func configureInitiatorImageView() {
        initiatorImageView.image = .defaultProfileImageSmallCircle
        initiatorImageView.contentMode = .scaleAspectFill
        initiatorImageView.clipsToBounds = true
        initiatorImageView.backgroundColor = .softPeach
        
        stackInitiatorView.addArrangedSubview(initiatorImageView)
        initiatorImageView.anchors.width.equal(23)
        initiatorImageView.anchors.height.equal(23)
    }
    
    func configureInitiatorNameLabel() {
        initiatorNameLabel.text = .placeholderWithSpaces()
        initiatorNameLabel.font = .roboto(.medium, size: 14)
        initiatorNameLabel.textColor = .night
        
        stackInitiatorView.addArrangedSubview(initiatorNameLabel)
    }
    
    func configureArrowView() {
        arrowView.backgroundColor = .clear
        arrowView.image = .iconArrowRightGrey?.withTintColor(.boulder)
        arrowView.contentMode = .scaleAspectFit
        
        stackInitiatorView.addArrangedSubview(arrowView)
        stackInitiatorView.addArrangedSubview(invisibleView())
        
        arrowView.anchors.width.equal(7)
        arrowView.anchors.height.equal(10)
    }
    
    func configureStackContainerHorizontal() {
        stackContainerHorizontal.spacing = 8
        stackContainerHorizontal.alignment = .top
        
        stackContainerVertical.addArrangedSubview(stackContainerHorizontal)
    }
    
    func configureStackContent() {
        stackContent.axis = .vertical
        stackContent.spacing = 10
        
        stackContainerHorizontal.addArrangedSubview(stackContent)
        
        configureStackInfo()
    }
    
    func configureDonationPhotoImageView() {
        donationPhotoImageView.contentMode = .scaleAspectFill
        donationPhotoImageView.backgroundColor = .softPeach
        donationPhotoImageView.layer.cornerRadius = 4
        donationPhotoImageView.clipsToBounds = true
        
        stackContainerHorizontal.addArrangedSubview(donationPhotoImageView)
        donationPhotoImageView.anchors.width.equal(87)
        donationPhotoImageView.anchors.height.equal(87)
    }
    
    func configureStackInfo() {
        stackInfo.axis = .vertical
        stackInfo.spacing = 4
        
        stackContent.addArrangedSubview(stackInfo)
        
        configureDonationTitleLabel()
    }
    
    func configureDonationTitleLabel() {
        donationTitleLabel.text = .placeholderWithSpaces(count: 100)
        donationTitleLabel.textColor = .boulder
        donationTitleLabel.font = .roboto(.regular, size: 14)
        donationTitleLabel.numberOfLines = 0
        donationTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        stackInfo.addArrangedSubview(donationTitleLabel)
    }
}
