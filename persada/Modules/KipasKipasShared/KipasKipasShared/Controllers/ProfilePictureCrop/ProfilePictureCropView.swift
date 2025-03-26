import UIKit
import KipasKipasShared

class ProfilePictureCropView: UIView {
    var imageAreaHeightAnchor = NSLayoutConstraint()
    var imageAreaWidthAnchor = NSLayoutConstraint()
    
    lazy var titleView: UIView = {
        let label = UILabel()
        label.text = "Crop"
        label.font = .roboto(.medium, size: 14)
        label.textColor = .black
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        label.centerXTo(view.centerXAnchor)
        label.centerYTo(view.centerYAnchor)
        
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.layer.cornerRadius = 20
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .whiteSnow
        return scrollView
    }()
    
    lazy var descriptionView: UIView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.image = .iconMove
        
        let label = UILabel()
        label.text = "Geser gambar untuk atur posisi"
        label.textColor = .placeholder
        label.font = .roboto(.medium, size: 10)
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([icon, label])
        icon.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor)
        label.anchor(top: view.topAnchor, left: icon.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8)
        
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var cancelButton: KKBaseButton = {
        let button = KKBaseButton()
        button.setTitle("Batalkan")
        button.setTitleColor(.contentGrey, for: .normal)
        button.backgroundColor = .whiteSnow
        button.font = .roboto(.bold, size: 14)
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var saveButton: KKBaseButton = {
        let button = KKBaseButton()
        button.setTitle("Simpan")
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .watermelon
        button.font = .roboto(.bold, size: 14)
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var actionView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillProportionally
        view.spacing = 8
        
        cancelButton.anchor(height: 40)
        saveButton.anchor(height: 40)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubviews([titleView, actionView, scrollView, descriptionView])
        titleView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, height: 56)
        actionView.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 24, paddingRight: 24)
        
        imageAreaWidthAnchor = scrollView.widthAnchor.constraint(equalToConstant: 320)
        imageAreaHeightAnchor = scrollView.heightAnchor.constraint(equalToConstant: 320)
        imageAreaWidthAnchor.isActive = true
        imageAreaHeightAnchor.isActive = true
        scrollView.centerXTo(centerXAnchor)
        scrollView.centerYTo(centerYAnchor)
        scrollView.addSubview(imageView)
        imageView.anchors.edges.pin()
        
        descriptionView.anchor(top: scrollView.bottomAnchor, paddingTop: 12)
        descriptionView.centerXTo(centerXAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
