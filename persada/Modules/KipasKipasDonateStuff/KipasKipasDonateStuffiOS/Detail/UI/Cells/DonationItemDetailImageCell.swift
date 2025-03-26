import UIKit
import KipasKipasShared

final class DonationItemDetailImageCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    var onReuse: EmptyClosure?
    
    private var offset: CGPoint = .zero {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if offset.y < 0 {
            let height = max(bounds.height - offset.y / 1.25, bounds.height)
            self.imageView.frame = CGRect(x: 0, y: offset.y, width: bounds.width, height: height)
            
        } else {
            let parallaxFactor: CGFloat = 0.7
            let newFrame = bounds.offsetBy(dx: 0, dy: (offset.y * parallaxFactor))
            self.imageView.frame = newFrame
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        offset = .zero
        onReuse?()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
        
        if let collectionView = superview as? UICollectionView {
            let offset = collectionView.contentOffset
            setZoomOffset(offset: offset)
        }
    }
    
    func setZoomOffset(offset: CGPoint) {
        self.offset = offset
    }
}

// MARK: UI
private extension DonationItemDetailImageCell {
    func configureUI() {
        configureImageView()
    }
    
    func configureImageView() {
        imageView.backgroundColor = .softPeach
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
    }
}
