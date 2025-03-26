import UIKit
import KipasKipasShared

class CameraPagingView: PagingView {
    
    private let stackContainer = UIStackView()
    
    private(set) lazy var stackView = UIStackView()
    private(set) lazy var photoView = KKBaseButton()
    private(set) lazy var rotateButton = KKBaseButton()
    
    override func configure() {
        configureUI()
    }
    
    override func setupConstraints() {}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
    }
    
    // MARK: UI
    private func configureUI() {
        configureStackContainer()
        configurePageView()
        configureStackView()
        configurePhotoView()
        configureCollectionView()
        configureRotateButton()
    }
    
    private func configureStackContainer() {
        stackContainer.axis = .vertical
        
        addSubview(stackContainer)
        stackContainer.anchors.edges.pin()
    }
    
    private func configureStackView() {
        stackView.spacing = 20
        stackView.backgroundColor = .night
        stackView.alignment = .center
        
        stackContainer.addArrangedSubview(stackView)
        stackView.anchors.height.equal(92)
        stackView.anchors.bottom.pin()
    }
    
    private func configurePhotoView() {
        photoView.backgroundColor = .boulder
        photoView.layer.cornerRadius = 2
        photoView.layer.borderColor = UIColor.white.cgColor
        photoView.layer.borderWidth = 1
        photoView.clipsToBounds = true
        photoView.imageView?.contentMode = .scaleAspectFill
        
        stackView.addArrangedSubview(spacerWidth(8))
        stackView.addArrangedSubview(photoView)
        photoView.anchors.width.equal(24)
        photoView.anchors.height.equal(24)
    }
    
    private func configureCollectionView() {
        stackView.addArrangedSubview(collectionView)
        collectionView.anchors.height.equal(stackView.anchors.height)
    }
    
    private func configureRotateButton() {
        rotateButton.backgroundColor = .clear
        rotateButton.setImage(.iconRotate)
        rotateButton.imageView?.contentMode = .scaleAspectFill
        
        stackView.addArrangedSubview(rotateButton)
        stackView.addArrangedSubview(spacerWidth(8))
        rotateButton.anchors.width.equal(24)
        rotateButton.anchors.height.equal(24)
    }
    
    private func configurePageView() {
        stackContainer.addArrangedSubview(pageView)
    }
}
