import UIKit
import KipasKipasShared

final class TopSeatView: UIView {
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var ribbonColor: UIColor? {
        didSet {
            ribbonView.backgroundColor = ribbonColor
        }
    }
    
    var ribbonText: String? {
        didSet {
            ribbonLabel.text = ribbonText
        }
    }
    
    private let imageView = UIImageView()
    private let ribbonView = UIView()
    private let ribbonLabel = UILabel()
    
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
        imageView.layer.cornerRadius = bounds.width / 2
        ribbonView.layer.cornerRadius = bounds.width / 6
    }
    
    func setProfileImage(_ imageURL: String?, isExists: Bool) {
        imageView.contentMode = imageURL == nil ? .center : .scaleAspectFill

        if isExists {
            imageView.contentMode = imageURL?.isEmpty == true ? .center : .scaleAspectFill
            imageView.setImage(with: imageURL, placeholder: .defaultProfileImageSmall)
        } else {
            imageView.image = image
        }
    }
}

// MARK: UI
private extension TopSeatView {
    func configureUI() {
        backgroundColor = .clear
        
        configureImageView()
        configureRibbonView()
    }
    
    func configureImageView() {
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        
        addSubview(imageView)
        imageView.anchors.edges.pin()
    }
    
    func configureRibbonView() {
        addSubview(ribbonView)
        ribbonView.anchors.height.equal(anchors.height * 0.35)
        ribbonView.anchors.edges.pin(axis: .horizontal)
        ribbonView.anchors.bottom.pin()
        
        ribbonLabel.textAlignment = .center
        ribbonLabel.font = .roboto(.black, size: 7)
        ribbonLabel.textColor = .black
        
        ribbonView.addSubview(ribbonLabel)
        ribbonLabel.anchors.edges.pin()
    }
}
