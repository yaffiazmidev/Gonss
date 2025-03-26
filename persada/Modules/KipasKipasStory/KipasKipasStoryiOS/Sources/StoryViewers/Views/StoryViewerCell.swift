import UIKit
import KipasKipasShared
import KipasKipasStory
import KipasKipasImage

final class StoryViewerCell: UICollectionViewCell {
    
    // MARK: Callbacks
    var onTapFollow: EmptyClosure?
    var onTapSendMessage: EmptyClosure?
    var onTapProfile: EmptyClosure?
    
    var onReuse: EmptyClosure?
    
    private let containerView = UIView()
    private let photoView = StoryViewerPhotoView()
    
    private let stackLabel = UIStackView()
    private let nameLabel = UILabel()
    private let verifiedIcon = UIImageView()
    
    private let actionButton = KKBaseButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        actionButton.removeTarget(nil, action: nil, for: .allEvents)
        onReuse?()
    }
    
    // MARK: API
    func configure(with viewModel: StoryViewerViewModel) {
        fetchPhoto(viewModel.photoURL)
        configureButtonState(viewModel.accountState)
        
        nameLabel.text = viewModel.name
        verifiedIcon.isHidden = viewModel.isVerified == false
        photoView.reactionView.isHidden = viewModel.isLiked == false
    }
    
    private func fetchPhoto(_ url: URL?) {
        fetchImage(
            with: .init(url: url, size: .w_50),
            into: photoView.imageView,
            isTransitioning: true
        )
    }
    
    private func configureButtonState(_ state: StoryViewerViewModel.AccountState) {
        switch state {
        case .follow:
            actionButton.setTitle("Ikuti")
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.backgroundColor = .watermelon
            actionButton.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        case .message:
            actionButton.setTitle("Kirim Pesan")
            actionButton.setTitleColor(.gravel, for: .normal)
            actionButton.backgroundColor = UIColor(hexString: "#f1f1f2")
            actionButton.addTarget(self, action: #selector(didTapSendMessage), for: .touchUpInside)
        }
    }
    
    @objc private func didTapFollow() {
        onTapFollow?()
    }
    
    @objc private func didTapSendMessage() {
        onTapSendMessage?()
    }
    
    @objc private func didTapProfile() {
        onTapProfile?()
    }
}

private extension StoryViewerCell {
    func configureUI() {
        configureContainerView()
        configurePhotoView()
        configureActionButton()
        configureStackLabel()
    }
    
    func configureContainerView() {
        containerView.backgroundColor = .white
        containerView.isUserInteractionEnabled = true
        
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func configurePhotoView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        photoView.addGestureRecognizer(tap)
        photoView.backgroundColor = .clear
        photoView.isUserInteractionEnabled = true
        
        containerView.addSubview(photoView)
        photoView.anchors.width.equal(53)
        photoView.anchors.height.equal(53)
        photoView.anchors.leading.pin(inset: 16)
        photoView.anchors.centerY.align()
    }
    
    func configureStackLabel() {
        stackLabel.spacing = 2
        stackLabel.alignment = .center
        
        containerView.addSubview(stackLabel)
        stackLabel.anchors.leading.spacing(12, to: photoView.anchors.trailing)
        stackLabel.anchors.centerY.align()
        stackLabel.anchors.trailing.spacing(12, to: actionButton.anchors.leading)
        
        configureUsernameLabel()
        configureVerifiedIcon()
        stackLabel.addArrangedSubview(invisibleView())
    }
    
    func configureUsernameLabel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        nameLabel.addGestureRecognizer(tap)
        nameLabel.font = .roboto(.medium, size: 16)
        nameLabel.textColor = .night
        nameLabel.isUserInteractionEnabled = true
        
        stackLabel.addArrangedSubview(nameLabel)
    }
    
    func configureVerifiedIcon() {
        verifiedIcon.image = .iconVerified
        verifiedIcon.backgroundColor = .clear
        verifiedIcon.clipsToBounds = true
        verifiedIcon.isHidden = true
        
        stackLabel.addArrangedSubview(verifiedIcon)
        verifiedIcon.anchors.width.equal(18)
        verifiedIcon.anchors.height.equal(18)
    }
    
    func configureActionButton() {
        actionButton.font = .roboto(.bold, size: 12)
        actionButton.setTitleColor(.clear, for: .normal)
        actionButton.backgroundColor = .clear
        actionButton.layer.cornerRadius = 4
        
        containerView.addSubview(actionButton)
        actionButton.anchors.trailing.pin(inset: 16)
        actionButton.anchors.width.equal(84)
        actionButton.anchors.height.equal(29)
        actionButton.anchors.centerY.align()
    }
}

