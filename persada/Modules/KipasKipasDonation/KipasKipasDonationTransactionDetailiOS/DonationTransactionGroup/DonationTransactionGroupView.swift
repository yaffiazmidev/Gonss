import UIKit
import KipasKipasShared

public class DonationTransactionGroupView: UIView {
    
    private(set) lazy var containerView: UIView = UIView()
    private(set) var backgroundContainer: UIView = UIView()
    private(set) lazy var closeButton: UIButton = UIButton()
    private(set) lazy var collectionView: UICollectionView = UICollectionView()
    private(set) lazy var titleLabel: UILabel = UILabel()
    var commentTextViewHeightConstraint: NSLayoutConstraint?
    var handleTapClose: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        UIFont.loadCustomFonts
        configureBackgroundContainer()
        configureContainerView()
    }
    
    private func configureBackgroundContainer() {
        addSubview(backgroundContainer)
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainer.backgroundColor = .black
        backgroundContainer.alpha = 0.6
        backgroundContainer.accessibilityIdentifier = "backgroundContainer"
        backgroundContainer.anchors.edges.pin()
        
        let onTapBackgroundContainerGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapBackgroundClose))
        backgroundContainer.isUserInteractionEnabled = true
        backgroundContainer.addGestureRecognizer(onTapBackgroundContainerGesture)
    }
    
    private func configureContainerView() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .whiteSmoke
        containerView.layer.cornerRadius = 10
        containerView.accessibilityIdentifier = "containerView"
        containerView.anchors.leading.equal(self.anchors.leading)
        containerView.anchors.trailing.equal(self.anchors.trailing)
        containerView.anchors.top.greaterThanOrEqual(self.anchors.top, constant: 100)
        containerView.anchors.height.equal(450)
        containerView.anchors.bottom.equal(self.anchors.bottom, constant: 0)
        
        configureCloseButton()
        configureTitleLabel()
        configureCollectionView()
    }
    
    func configureCloseButton() {
        containerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.contentMode = .scaleAspectFill
        closeButton.clipsToBounds = true
        closeButton.accessibilityIdentifier = "closeButton"
        closeButton.isUserInteractionEnabled = true
        closeButton.setImage(.iconCommentClose?.withTintColor(.black, renderingMode: .alwaysOriginal))
        closeButton.anchors.trailing.equal(containerView.anchors.trailing, constant: -10)
        closeButton.anchors.top.equal(containerView.safeAreaLayoutGuide.anchors.top, constant: 8)
        closeButton.anchors.height.equal(24)
        closeButton.anchors.width.equal(24)
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
    }
    
    func configureTitleLabel() {
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Grup Donasi"
        titleLabel.font = .roboto(.bold, size: 14)
        titleLabel.textColor = .black
        titleLabel.accessibilityIdentifier = "titleLabel"
        titleLabel.anchors.top.equal(containerView.safeAreaLayoutGuide.anchors.top, constant: 14)
        titleLabel.anchors.centerX.equal(containerView.anchors.centerX)
    }
    
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        containerView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = false
        collectionView.accessibilityIdentifier = "collectionView"
        collectionView.backgroundColor = .clear
        
        collectionView.anchors.top.equal(titleLabel.anchors.bottom, constant: 8)
        collectionView.anchors.leading.equal(containerView.anchors.leading, constant: 16)
        collectionView.anchors.trailing.equal(containerView.anchors.trailing, constant: -16)
        collectionView.anchors.bottom.equal(containerView.safeAreaLayoutGuide.anchors.bottom)
    }
    
    @objc func handleClose() {
        self.handleTapClose?()
    }
    
    @objc func handleTapBackgroundClose() {
        self.handleTapClose?()
    }
}

