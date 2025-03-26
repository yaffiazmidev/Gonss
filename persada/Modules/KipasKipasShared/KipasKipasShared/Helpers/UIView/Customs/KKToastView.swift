import UIKit

public final class KKToastView: UIView {
    
    private enum State {
        case prepare
        case visible
    }
    
    public enum Direction {
        case top
        case bottom
    }
    
    public enum DismissTransition {
        case begin
        case fade
    }
    
    public enum VisiblePosition {
        case top
        case center
        case bottom
    }
    
    public var color: UIColor = UIColor(hexString: "#FFE4B5") {
        didSet { updateAppearance() }
    }
    
    public var cornerRadius: CGFloat = 0 {
        didSet { updateAppearance()}
    }
  
    public var direction: Direction = .top
    public var visiblePosition: VisiblePosition = .top
    public var dismissTransition: DismissTransition = .begin
    public var insets: UIEdgeInsets = .zero
    
    public var onTap: EmptyClosure?
    
    private let container = UIImageView()
    private let stackView = UIStackView()
    
    public let messageLabel = UILabel()
    
    private var completion: EmptyClosure?
    
    private lazy var intrinsicSize: CGSize = {
        let targetSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let intrinsicSize = systemLayoutSizeFitting(targetSize)
        return intrinsicSize
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: API
    public func setBackgroundImage(_ image: UIImage?) {
        container.image = image
        container.backgroundColor = image == nil ? .clear : .red
    }
    
    /// Presentation
    public func present(duration: TimeInterval, completion: EmptyClosure? = nil) {
        prepareForPresentation(completion: completion)
        present(duration: duration)
    }
    
    private func updateAppearance() {
        container.backgroundColor = color
        container.layer.cornerRadius = cornerRadius
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
    
    public func dismiss() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            if self.dismissTransition == .begin {
                self.changeState(.prepare)
            } else {
                self.alpha = 0
            }
        }, completion: { _ in
            self.layer.removeAllAnimations()
            self.removeFromSuperview()
            self.completion?()
        })
    }
    
    private func prepareForPresentation(completion: EmptyClosure? = nil) {
        guard let window = appWindow else { return }
        window.addSubview(self)
        
        messageLabel.sizeToFit()
        
        var finalWidth = intrinsicSize.width
        
        if finalWidth >= window.frame.width {
            finalWidth = messageLabel.frame.width - insets.left - insets.right
        }
        
        anchors.width.equal(finalWidth)
        anchors.centerX.align()

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
        
        switch visiblePosition {
        case .top:
            let position = intrinsicSize.height
            return CGAffineTransform.identity.translatedBy(x: 0, y: position)
            
        case .center:
            let inset = direction == .top ? insets.top : insets.bottom
            let position = window.center.y - inset
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
        onTap?()
    }
}

// MARK: UI
private extension KKToastView {
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
        
        configureSpacer(8)
        configureMessageLabel()
        configureSpacer(8)
    }
    
    func configureSpacer(_ width: CGFloat) {
        stackView.addArrangedSubview(spacerWidth(width))
    }
    
    // MARK: Message Label
    func configureMessageLabel() {
        messageLabel.font = .roboto(.medium, size: 12)
        messageLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(messageLabel)
    }
}

