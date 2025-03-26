import UIKit

public final class EmptyView: UIView {
    
    private let container = ScrollContainerView()
    private let imageView = UIImageView()
    private let messageLabel = UILabel()
    
    private let image: UIImage?
    private let message: String
    private let contentSpacing: CGFloat
    private let horizontalInsets: CGFloat
    
    public init(
        image: UIImage? = nil,
        message: String,
        contentSpacing: CGFloat = 12.0,
        horizontalInsets: CGFloat = 0.0
    ) {
        self.image = image
        self.message = message
        self.contentSpacing = contentSpacing
        self.horizontalInsets = horizontalInsets
        super.init(frame: .zero)
        
        configureUI()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
}

private extension EmptyView {
    var adaptedHorizontalInsets: CGFloat {
        adapted(dimensionSize: horizontalInsets, to: .width)
    }
}

// MARK: UI
private extension EmptyView {
    func configureUI() {
        backgroundColor = .clear
        configureContainer()
    }
    
    func configureContainer() {
        container.isCentered = true
        container.alignment = .center
        container.isScrollEnabled = false
        container.contentInsetAdjustmentBehavior = .never
        container.spacingBetween = contentSpacing
        
        addSubview(container)
        container.anchors.center.align()
        container.anchors.edges.pin(insets: adaptedHorizontalInsets, axis: .horizontal)
        
        configureImageView()
        configureMessageLabel()
    }
    
    func configureImageView() {
        imageView.isHidden = image == nil
        imageView.image = image
        container.addArrangedSubViews(imageView)
    }
    
    func configureMessageLabel() {
        messageLabel.text = message
        messageLabel.font = .roboto(.regular, size: 15)
        messageLabel.textColor = .ashGrey
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 2
        container.addArrangedSubViews(messageLabel)
    }
}
