//
//  FloatingLinkView.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 02/01/24.
//

import UIKit
import KipasKipasShared
import Kingfisher

protocol FloatingLinkViewDelegate: AnyObject {
    func didClose()
    func didOpen()  
}

class FloatingLinkView: FloatingStackView {
    
    weak var delegate: FloatingLinkViewDelegate?
    private let userImageViewSize: CGFloat = 30
    private let titleImageViewHeight: CGFloat = 12
    
    private lazy var iconCloseView: UIView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: .get(.iconCloseCircle))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.anchor(width: 14, height: 14)
        imageView.centerXToSuperview()
        imageView.centerYToSuperview()
        
        return view
    }()
    
    private lazy var userImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: .get(.iconLinkPlaceholder))
        view.backgroundColor = UIColor(hexString: "#FFFFFF")
        view.layer.cornerRadius = userImageViewSize / 2
        view.layer.borderColor = UIColor(hexString: "#FE3848").cgColor
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Floating Link"
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var titleImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        view.anchor(height: titleImageViewHeight)
        
        return view
    }()
    
    private lazy var titleView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, titleImageView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(top: 2, left: 4, bottom: 2, right: 4)
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.axis = .horizontal
        view.spacing = 2
        view.layer.cornerRadius = 4
        view.heightAnchor.constraint(lessThanOrEqualToConstant: 25).isActive = true
        
        return view
    }()
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([userImageView, titleView, iconCloseView])
        titleView.anchor(bottom: view.bottomAnchor)
        userImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingBottom: 8, width: userImageViewSize, height: userImageViewSize)
        userImageView.centerXTo(titleView.centerXAnchor)
        iconCloseView.anchor(width: 32, height: 32)
        iconCloseView.centerXTo(userImageView.rightAnchor)
        iconCloseView.centerYTo(userImageView.topAnchor)
        return view
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addArrangedSubview(mainView)
        setupGestures()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addArrangedSubview(mainView)
        setupGestures()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FloatingLinkView {
    func setupView(title: String?, siteName: String?, siteLogo: String?, accountPhotoUrl: String?) {
        titleLabel.text = title?.trim() ?? "Floating Link"
        if let imageUrl = accountPhotoUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            userImageView.kf.setImage(with: url, placeholder: UIImage(named: .get(.iconProfilePlaceholder))) { [weak self] (result) in
                self?.handleTitleImageViewResult(result)
            }
        }
        
        switch siteName?.lowercased() {
        case "youtube", "instagram":
            if let logo = siteLogo, !logo.isEmpty, let url = URL(string: logo) {
                titleLabel.isHidden = true
                titleImageView.isHidden = false
                titleImageView.kf.setImage(with: url) { [weak self] (result) in
                    self?.handleTitleImageViewResult(result)
                }
            }
        default: break
        }
        
        updateHorizontalMargin()
    }
}

// MARK: - Private Helper
extension FloatingLinkView {
    private func setupGestures() {
        titleView.onTap { [weak self] in
            self?.delegate?.didOpen()
        }
        
        userImageView.onTap { [weak self] in
            self?.delegate?.didOpen()
        }
        
        iconCloseView.onTap { [weak self] in
            self?.delegate?.didClose()
        }
    }
    
    private func updateHorizontalMargin() {
//        if titleView.bounds.width > userImageViewSize {
//            let different = (titleView.bounds.width - userImageViewSize) / 2
//            viewMargin.left += different
//            viewMargin.right += different
//            
//            //Simulate gesture, for update position
//            let panGesture = UIPanGestureRecognizer()
//            let simulatedLocation = CGPoint(x: bounds.minX, y: bounds.minY)
//            panGesture.setTranslation(simulatedLocation, in: superview)
//            panGesture.state = .changed
//            handleDrag(gesture: panGesture)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                panGesture.state = .ended
//                self.handleDrag(gesture: panGesture)
//            }
//        }
    }
}

// MARK: - Image Loader Handler
extension FloatingLinkView {
    private func handleTitleImageViewResult(_ result: Result<RetrieveImageResult, KingfisherError>) {
        switch result {
        case .success(let result):
            let aspectRatio = result.image.size.width / result.image.size.height
            let scaledWidth = titleImageViewHeight * aspectRatio
            titleImageView.anchor(width: scaledWidth, height: titleImageViewHeight)
            updateHorizontalMargin()
        case .failure(_):
            titleLabel.isHidden = false
            titleImageView.isHidden = true
        }
    }
    
    private func handleUserImageViewResult(_ result: Result<RetrieveImageResult, KingfisherError>) {
        switch result {
        case .success(_):
            userImageView.contentMode = .scaleAspectFill
        case .failure(_):
            userImageView.image = UIImage(named: .get(.iconLinkPlaceholder))
        }
    }
}

fileprivate extension String {
    func trim(limit: Int = 16) -> String {
        let nsString = self as NSString
        if nsString.length >= limit {
            var trim = nsString.substring(with: NSRange(location: 0, length: nsString.length > limit ? limit : nsString.length))
            if trim.count == limit {
                trim += "..."
            }
            return trim
        }
        return self
    }
}
