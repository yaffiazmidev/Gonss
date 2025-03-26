import UIKit

public final class CollectionEmptyCell: UICollectionViewCell {
    
    private let stackView = UIStackView()
    
    // MARK: Image
    private let imageView = UIImageView()
    
    private lazy var imageGroupView: GroupView = {
        let groupView = GroupView(views: [imageView, spacer(14)])
        return groupView
    }()
    
    private var imageSize: CGSize = .zero {
        didSet {
            imageWidthConstraint.constant = adapted(dimensionSize: imageSize.width, to: .width)
            imageHeightConstraint.constant =  adapted(dimensionSize: imageSize.height, to: .height)
        }
    }
    
    private var imageWidthConstraint: NSLayoutConstraint! {
        didSet { imageWidthConstraint.isActive = true }
    }
    
    private var imageHeightConstraint: NSLayoutConstraint! {
        didSet { imageHeightConstraint.isActive = true }
    }
    
    // MARK: Message
    private let messageLabel = UILabel()
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: API
    func configure(with viewModel: CollectionEmptyViewModel) {
        imageSize = viewModel.imageSize
        imageView.image = viewModel.image
        imageGroupView.isHidden = viewModel.image == nil
        
        messageLabel.text = viewModel.message
        messageLabel.font = viewModel.messageFont
    }
}

// MARK: UI
private extension CollectionEmptyCell {
    func configureUI() {
        configureStackView()
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.backgroundColor = .white
        
        addSubview(stackView)
        stackView.anchors.edges.pin(axis: .horizontal)
        stackView.anchors.center.align()
        
        configureImageView()
        configureMessageLabel()
    }
    
    func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
    
        imageWidthConstraint = imageView.anchors.width.equal(imageSize.width)
        imageHeightConstraint = imageView.anchors.height.equal(imageSize.height)
        
        stackView.addArrangedSubview(imageGroupView)
    }
    
    func configureMessageLabel() {
        messageLabel.textColor = .boulder
        
        stackView.addArrangedSubview(messageLabel)
    }
}
