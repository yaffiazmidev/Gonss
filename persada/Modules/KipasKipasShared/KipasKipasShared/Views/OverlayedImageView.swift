import UIKit

public final class OverlayedImageView: UIView {
    
    public var overlayAlpha: CGFloat = 0.6
    
    public var overlayColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override var contentMode: UIView.ContentMode {
        didSet {
            imageView.contentMode = contentMode
        }
    }
    
    public var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    
    private let imageView = UIImageView()
    private let overlayLayer = CALayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        imageView.clipsToBounds = true
        
        let color = overlayColor.withAlphaComponent(overlayAlpha)
        overlayLayer.backgroundColor = color.cgColor
        overlayLayer.frame = bounds
        overlayLayer.position = center
        
        layer.addSublayer(overlayLayer)
    }
}
