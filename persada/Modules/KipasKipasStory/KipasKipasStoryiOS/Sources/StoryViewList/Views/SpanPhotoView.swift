import UIKit
import KipasKipasShared

class SpanPhotoView: UIView {
    
    private let stackView = UIStackView()
    
    let firstImageView = UIImageView()
    let secondImageView = UIImageView()
    
    private let dimension: CGFloat
    
    init(dimension: CGFloat) {
        self.dimension = dimension
        super.init(frame: .zero)
        
        configureStackView()
        configureCommonStyle(firstImageView)
        configureCommonStyle(secondImageView)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func configureStackView() {
        stackView.spacing = -10
        addSubview(stackView)
        
        stackView.anchors.edges.pin()
    }
    
    func configureCommonStyle(_ imageView: UIImageView) {
        imageView.backgroundColor = .systemGray2
        imageView.layer.borderColor = UIColor.night.cgColor
        imageView.layer.borderWidth = 2
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = dimension / 2
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        
        stackView.addArrangedSubview(imageView)
        imageView.anchors.width.equal(dimension)
        imageView.anchors.height.equal(dimension)
    }
}

