import UIKit
import KipasKipasShared

open class CaptureButton: UIView {
    
    private(set) public lazy var containerView = UIView()
    private(set) public lazy var borderView = UIView()
    private(set) public lazy var captureButton = KKBaseButton()
    
    public var didTapButton: (() -> Void)?
    
    public var buttonColor: UIColor = .white {
        didSet {
            captureButton.backgroundColor = buttonColor
        }
    }
    
    public var borderColor: UIColor = .white {
        didSet {
            borderView.layer.borderColor = borderColor.cgColor
        }
    }
    
    public var borderWidth: CGFloat = 2.0 {
        didSet {
            borderView.layer.borderWidth = borderWidth
        }
    }
    
    // MARK: Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = containerView.bounds.height / 2
        borderView.layer.cornerRadius = borderView.bounds.height / 2
        captureButton.layer.cornerRadius = captureButton.bounds.height / 2
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: UI
private extension CaptureButton {
    private func configureUI() {
        configureContainerView()
        configureBorderView()
        configureCaptureButton()
        configureAppearance()
    }
    
    private func configureAppearance() {
        captureButton.backgroundColor = buttonColor
        borderView.layer.borderColor = borderColor.cgColor
        borderView.layer.borderWidth = borderWidth
    }

    private func configureContainerView() {
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = true
        
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    private func configureBorderView() {
        borderView.backgroundColor = .clear
        borderView.clipsToBounds = true
        
        addSubview(borderView)
        borderView.anchors.edges.pin()
    }

    private func configureCaptureButton() {
        captureButton.clipsToBounds = true
        captureButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        
        addSubview(captureButton)
        captureButton.anchors.edges.pin(insets: 8)
    }

    @objc private func didTap() {
        didTapButton?()
    }
}
