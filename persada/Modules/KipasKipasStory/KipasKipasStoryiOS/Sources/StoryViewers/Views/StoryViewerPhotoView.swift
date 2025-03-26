import UIKit
import KipasKipasShared

final class StoryViewerPhotoView: UIView {
    
    let imageView = UIImageView()
    let reactionView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        imageView.layer.cornerRadius = bounds.height / 2
        
        let ratio: CGFloat = (0.35 * bounds.height).rounded()
        let margin: CGFloat = 2
        let x = bounds.width - ratio + margin
        let y = bounds.height - ratio + margin
        
        reactionView.frame = .init(x: x, y: y, width: ratio, height: ratio)
        reactionView.layer.cornerRadius = ratio / 2
    }
}

// MARK: UI
private extension StoryViewerPhotoView {
    func configureUI() {
        configureImageView()
        configureReactionView()
    }
    
    func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .softPeach
        
        addSubview(imageView)
    }
    
    func configureReactionView() {
        reactionView.contentMode = .scaleAspectFit
        reactionView.image = .iconLikeFillPink
        reactionView.clipsToBounds = true
        reactionView.layer.borderColor = UIColor.white.cgColor
        reactionView.layer.borderWidth = 2
        reactionView.layer.masksToBounds = true
        reactionView.isHidden = true
        
        addSubview(reactionView)
    }
}

