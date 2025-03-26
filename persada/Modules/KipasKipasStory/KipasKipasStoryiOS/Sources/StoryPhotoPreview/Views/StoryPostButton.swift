import UIKit
import KipasKipasShared
import KipasKipasImage

final class StoryPostButton: UIButton {
    
    var photoURL: URL? {
        didSet { fetchImage(
            with: .init(url: photoURL, size: .w_36),
            into: photoView)
        }
    }
    
    private let stackView = UIStackView()
    private let button = KKBaseButton()
    
    private let imageContainer = UIView()
    private let photoView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: UI
private extension StoryPostButton {
    func configureUI() {
        configureStackView()
    }
    
    func configureStackView() {
        stackView.isUserInteractionEnabled = false
        stackView.alignment = .center
        stackView.spacing = 6
        
        addSubview(stackView)
        stackView.anchors.edges.pin(axis: .vertical)
        stackView.anchors.center.align()
        
        configureButtonContainer()
        configureButton()
    }
    
    func configureButtonContainer() {
        imageContainer.backgroundColor = .watermelon
        imageContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = 24 / 2
        
        stackView.addArrangedSubview(imageContainer)
        imageContainer.anchors.width.equal(24)
        imageContainer.anchors.height.equal(24)
        
        configureImageView()
    }
    
    func configureImageView() {
        photoView.backgroundColor = .white
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.layer.cornerRadius = 21 / 2
        
        imageContainer.addSubview(photoView)
        photoView.anchors.width.equal(21)
        photoView.anchors.height.equal(21)
        photoView.anchors.center.align()
    }
    
    func configureButton() {
        button.backgroundColor = .white
        button.setTitle("Tambahkan ke Story", for: .normal)
        button.font = .roboto(.medium, size: 14)
        button.setTitleColor(.night, for: .normal)
        
        stackView.addArrangedSubview(button)
    }
}
