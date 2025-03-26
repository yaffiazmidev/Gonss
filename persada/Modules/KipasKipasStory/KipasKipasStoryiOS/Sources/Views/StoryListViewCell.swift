//
//  StoryListViewCell.swift
//  KipasKipasStoryiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/06/24.
//

import UIKit
import KipasKipasStory
import KipasKipasShared

protocol StoryListViewCellDelegate: AnyObject {
    func didSelect(_ cell: StoryListViewCell)
    func didAddStory()
    func didRetryUpload()
    func didLive()
}

enum StoryListViewCellAction {
    case none
    case add
    case retry
    case live
}

class StoryListViewCell: UICollectionViewCell {
    
    private var profileSize: Double = 66
    private var statusSize: Double = 70
    private var actionSize: Double = 22
    
    private var action: StoryListViewCellAction = .none
    
    weak var delegate: StoryListViewCellDelegate?
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "Username"
        label.textColor = .black
        
        return label
    }()
    
    private lazy var statusView: UIView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = statusSize / 2
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        
        return view
    }()
    
    lazy var progressView: CircularProgressBar = {
        let view = CircularProgressBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.lineWidth = 2
        view.label.isHidden = true
        view.image.isHidden = true
        view.progressColor = .init(hexString: "1AE2C8")
        view.successColor = .init(hexString: "1AE2C8")
        view.lineBackgroundColor = .placeholder
        view.isHidden = true
        
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .defaultProfileImage
        view.backgroundColor = .grey.withAlphaComponent(0.5)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = profileSize / 2
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        
        return view
    }()
    
    private lazy var actionStoryImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.isHidden = true
        view.layer.cornerRadius = actionSize / 2
        
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubviews([statusView, progressView, profileImageView, actionStoryImageView])
        
        statusView.anchors.centerX.equal(view.anchors.centerX)
        statusView.anchors.centerY.equal(view.anchors.centerY)
        statusView.anchors.width.equal(statusSize)
        statusView.anchors.height.equal(statusSize)
        
        progressView.anchors.centerX.equal(view.anchors.centerX)
        progressView.anchors.centerY.equal(view.anchors.centerY)
        progressView.anchors.width.equal(statusSize)
        progressView.anchors.height.equal(statusSize)
        
        profileImageView.anchors.centerX.equal(view.anchors.centerX)
        profileImageView.anchors.centerY.equal(view.anchors.centerY)
        profileImageView.anchors.width.equal(profileSize)
        profileImageView.anchors.height.equal(profileSize)
        
        actionStoryImageView.anchors.trailing.equal(profileImageView.anchors.trailing, constant: 0)
        actionStoryImageView.anchors.bottom.equal(profileImageView.anchors.bottom, constant: 0)
        actionStoryImageView.anchors.height.equal(actionSize)
        actionStoryImageView.anchors.width.equal(actionSize)
        
        return view
    }()
    
    private lazy var mainView: UIView = {
        let usernameView = UIView()
        usernameView.translatesAutoresizingMaskIntoConstraints = false
        usernameView.addSubview(usernameLabel)
        usernameLabel.anchors.trailing.equal(usernameView.anchors.trailing)
        usernameLabel.anchors.leading.equal(usernameView.anchors.leading)
        usernameLabel.anchors.top.equal(usernameView.anchors.top)
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubviews([containerView, usernameView])
        
        containerView.anchors.leading.equal(view.anchors.leading)
        containerView.anchors.trailing.equal(view.anchors.trailing)
        containerView.anchors.top.equal(view.anchors.top)
        containerView.anchors.height.equal(78)
        
        usernameView.anchors.leading.equal(view.anchors.leading)
        usernameView.anchors.trailing.equal(view.anchors.trailing)
        usernameView.anchors.top.lessThanOrEqual(containerView.anchors.bottom, constant: 6)
        usernameView.anchors.bottom.equal(view.anchors.bottom)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

// MARK: - Helper
extension StoryListViewCell {
    /// color: for the parent background color
    /// label color: for text color
    /// border color: for border color arround profile picture/status(?)
    func configure(name: String, photo: String?, color: UIColor, labelColor: UIColor = .black, borderColor: UIColor = .clear, action: StoryListViewCellAction = .none) {
        usernameLabel.text = name
        usernameLabel.textColor = labelColor
        profileImageView.layer.borderColor = color.cgColor
        updateAction(action)
        updateStatusColor(borderColor)
        updateProfilePicture(photo)
    }
    
    func updateAction(_ action: StoryListViewCellAction) {
        self.action = action
        
        func updateIfNeeded(isHidden: Bool, image: UIImage?) {
            if actionStoryImageView.isHidden != isHidden {
                actionStoryImageView.isHidden = isHidden
            }
            
            if actionStoryImageView.image != image {
                actionStoryImageView.image = image
            }
        }
        
        switch action {
        case .none:
            updateIfNeeded(isHidden: true, image: nil)
        case .add:
            updateIfNeeded(isHidden: false, image: .iconBadgeAdd)
        case .retry:
            updateIfNeeded(isHidden: false, image: .iconBadgeRetry)
        case .live:
            updateIfNeeded(isHidden: false, image: .iconBadgeLive)
        }
    }
    
    func updateStatusColor(_ color: UIColor) {
        statusView.layer.borderColor = color.cgColor
    }
    
    func updateProfilePicture(_ string: String?) {
        profileImageView.loadProfileImage(from: string)
    }
}

// MARK: - Private Helper
private extension StoryListViewCell {
    private func configUI() {
        backgroundColor = .clear
        
        addSubview(mainView)
        
        mainView.anchors.leading.equal(anchors.leading)
        mainView.anchors.trailing.equal(anchors.trailing)
        mainView.anchors.bottom.equal(anchors.bottom)
        mainView.anchors.top.equal(anchors.top)
        setupGestures()
    }
    
    private func setupGestures() {
//        mainView.onTap { [weak self] in
//            guard let self = self else { return }
//            self.delegate?.didSelect(self)
//        }
//        
        actionStoryImageView.onTap { [weak self] in
            guard let self = self, !actionStoryImageView.isHidden else { return }
            switch self.action {
            case .add:
                self.delegate?.didAddStory()
            case .retry:
                self.delegate?.didRetryUpload()
            case .live:
                self.delegate?.didLive()
            default: break
            }
        }
    }
}
