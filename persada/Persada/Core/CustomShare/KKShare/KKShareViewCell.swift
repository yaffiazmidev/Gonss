import UIKit
import KipasKipasShared
import Kingfisher

class KKShareViewCell: UICollectionViewCell {

    let titleLabel: UILabel = UILabel()
    let imageView: UIImageView = UIImageView()
    let iconView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Data -

extension KKShareViewCell {
    
    func fillWithData(_ data: String, asset: String? = nil, url: String? = nil, isSelf: Bool = false) {
        titleLabel.text = isSelf ? "Add to Story" : data
        iconView.isHidden = !isSelf
        if let myAsset = asset {
            imageView.image = UIImage(named: myAsset)
        } else if let url = url {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: URL(string: url), placeholder: UIImage.defaultProfileImageCircle)
        } else {
            imageView.image = .defaultProfileImageCircle
        }
    }
}

// MARK: - UI -

private extension KKShareViewCell {
    
    func configureUI() {
        
        // Styling
        UIFont.loadCustomFonts
        titleLabel.font = .roboto(.regular, size: 10)
        titleLabel.textColor = UIColor(hexString: "#474747")
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        
        iconView.contentMode = .scaleAspectFit
        iconView.backgroundColor = .clear
        iconView.clipsToBounds = true
        iconView.image = UIImage(named: "iconAddStory")
        iconView.isHidden = true
    
        // Layout
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let container = self.contentView
        
        container.addSubview(titleLabel)
        container.addSubview(imageView)
        container.addSubview(iconView)
        
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        imageView.layer.cornerRadius = 25
        
        titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10).isActive = true
        titleLabel.topAnchor.constraint(lessThanOrEqualTo: imageView.bottomAnchor, constant: 9).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        iconView.anchors.width.equal(18)
        iconView.anchors.height.equal(18)
        iconView.anchors.trailing.equal(imageView.anchors.trailing)
        iconView.anchors.bottom.equal(imageView.anchors.bottom)
    }
}
