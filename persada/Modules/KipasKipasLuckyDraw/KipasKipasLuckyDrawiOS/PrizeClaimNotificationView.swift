import UIKit
import KipasKipasShared
import KipasKipasImage

final class PrizeClaimNotificationView: UIView {
    
    private enum State {
        case prepare
        case visible
    }
    
    enum Direction {
        case top
        case bottom
    }
    
    var color: UIColor = UIColor(hexString: "#FFE4B5")
    var direction: Direction = .top
    var onTapNotification: EmptyClosure?
    
    private let container = UIImageView()
    private let stackView = UIStackView()
    
    private let imageView = UIImageView()
    private let messageLabel = UILabel()
    private let closeButton = KKBaseButton()
    
    private var completion: EmptyClosure?
    
    private lazy var intrinsicSize: CGSize = {
        let targetSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let intrinsicSize = systemLayoutSizeFitting(targetSize)
        return intrinsicSize
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: API
    func setImageURL(_ url: URL?) {
        KipasKipasImage.fetchImage(
            with: .init(url: url, size: .w_50),
            into: imageView
        )
    }
    
    func setMessage(_ attributedMessage: NSAttributedString) {
        messageLabel.attributedText = attributedMessage
    }
    
    func setBackgroundImage(_ image: UIImage?) {
        container.image = image
        container.backgroundColor = image == nil ? .clear : .red
    }
    
    func setTintColor(_ color: UIColor) {
        let closeIcon = UIImage.LuckyDraw.iconXOutlined?.withTintColor(color)
        closeButton.setImage(closeIcon)
        messageLabel.textColor = color
    }
    
    /// Presentation
    func present(duration: TimeInterval, completion: EmptyClosure? = nil) {
        prepareForPresentation(completion: completion)
        present(duration: duration)
    }
    
    private func present(duration: TimeInterval) {
        isHidden = false
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.layer.removeAllAnimations()
            self.changeState(.visible)
            self.alpha = 1
        }, completion: { _ in
            if duration > 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    self.dismiss()
                }
            }
        })
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            self.changeState(.prepare)
        }, completion: { _ in
            self.layer.removeAllAnimations()
            self.removeFromSuperview()
            self.completion?()
        })
    }
    
    private func prepareForPresentation(completion: EmptyClosure? = nil) {
        guard let window = appWindow else { return }
        window.addSubview(self)
        
        anchors.edges.pin(insets: 16, axis: .horizontal)
        
        self.completion = completion
        self.alpha = 0
        self.isHidden = true
        changeState(.prepare)
    }
    
    private func changeState(_ state: State) {
        switch state {
        case .prepare:
            transform = getPrepareTransform()
        case .visible:
            transform = getVisibleTransform()
        }
    }
    
    private func getPrepareTransform() -> CGAffineTransform {
        guard let window = appWindow else { return .identity }
        
        switch direction {
        case .top:
            let topInset = window.safeAreaInsets.top
            let position = -(topInset + intrinsicSize.height)
            return CGAffineTransform.identity.translatedBy(x: 0, y: position)
            
        case .bottom:
            let windowHeight = window.frame.height
            let bottomInset = window.safeAreaInsets.bottom
            let position = windowHeight + bottomInset + intrinsicSize.height
            return CGAffineTransform.identity.translatedBy(x: 0, y: position)
        }
    }
    
    private func getVisibleTransform() -> CGAffineTransform {
        guard let window = appWindow else { return .identity }
        
        switch direction {
        case .top:
            let position = intrinsicSize.height
            return CGAffineTransform.identity.translatedBy(x: 0, y: position)
            
        case .bottom:
            let windowHeight = window.frame.height
            let bottomInset = window.safeAreaInsets.bottom
            let position = windowHeight - bottomInset - intrinsicSize.height
            return CGAffineTransform.identity.translatedBy(x: 0, y: position)
        }
    }
    
    // MARK: Action
    @objc private func didTapCloseButton() {
        dismiss()
    }
    
    @objc private func didTapNotification() {
        dismiss()
        onTapNotification?()
    }
}

// MARK: UI
private extension PrizeClaimNotificationView {
    func configureUI() {
        configureSelf()
        configureContainer()
        configureStackView()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapNotification))
        addGestureRecognizer(tapGesture)
    }
    
    func configureContainer() {
        container.isUserInteractionEnabled = true
        container.backgroundColor = .clear
        container.layer.cornerRadius = 10
        container.clipsToBounds = true
        container.contentMode = .redraw
        
        addSubview(container)
        container.anchors.edges.pin()
    }
    
    func configureStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        
        container.addSubview(stackView)
        stackView.anchors.edges.pin(insets: 10, axis: .horizontal)
        stackView.anchors.edges.pin(insets: 9, axis: .vertical)
        
        configureImageView()
        configureSpacer(8)
        configureMessageLabel()
        configureSpacer(8)
        configureCloseButton()
    }
    
    func configureSpacer(_ width: CGFloat) {
        stackView.addArrangedSubview(spacerWidth(width))
    }
    
    // MARK: Image
    func configureImageView() {
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .systemGray4
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        
        stackView.addArrangedSubview(imageView)
        imageView.anchors.width.equal(38)
        imageView.anchors.height.equal(38)
    }
    
    // MARK: Message Label
    func configureMessageLabel() {
        messageLabel.font = .roboto(.medium, size: 12)
        messageLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(messageLabel)
    }
    
    // MARK: Close Button
    func configureCloseButton() {
        closeButton.backgroundColor = .clear
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        stackView.addArrangedSubview(closeButton)
        closeButton.anchors.width.equal(20)
        closeButton.anchors.height.equal(20)
    }
}
