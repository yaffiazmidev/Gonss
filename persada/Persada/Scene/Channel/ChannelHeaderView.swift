import UIKit

class ChannelHeaderView: UICollectionReusableView {
    
    lazy var label: UILabel = {
        let label: UILabel = UILabel()
        label.adjustsFontForContentSizeCategory = false
        label.font = .Roboto(.medium, size: 16)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 14, paddingRight: 16)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
