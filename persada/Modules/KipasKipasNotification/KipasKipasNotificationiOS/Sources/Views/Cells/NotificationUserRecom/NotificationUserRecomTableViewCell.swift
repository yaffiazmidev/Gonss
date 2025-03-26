//
//  NotificationUserRecomTableViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 19/03/24.
//

import UIKit
import KipasKipasShared
import KipasKipasNotification

protocol NotificationUserRecomTableViewCellDelegate: AnyObject {
    func didClickFollow(by id: String)
    func didClickFollowing(by id: String)
    func didClickMessage(by id: String)
    func navigateToUserProfile(by id: String)
}

class NotificationUserRecomTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var verifiedIconImageView: UIImageView!
    @IBOutlet weak var closeIconContainerStackView: UIStackView!
    @IBOutlet weak var followTitleLabel: UILabel!
    @IBOutlet weak var firstMutualUserProfileImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    weak var delegate: NotificationUserRecomTableViewCellDelegate?
    var item: NotificationSuggestionAccountItem?
    
    var handleTapCloseButton: (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
        delegate = nil
        handleTapCloseButton = nil
        usernameLabel.text = nil
        subtitleLabel.text = nil
        profileImageView.cancelLoad()
        firstMutualUserProfileImageView.cancelLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        verifiedIconImageView.image = UIImage.iconVerified
        
        let onTapFollowTitleLabelGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapFollowButton))
        followTitleLabel.isUserInteractionEnabled = true
        followTitleLabel.addGestureRecognizer(onTapFollowTitleLabelGesture)
        
        let onTapCloseIconGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapCloseButton))
        closeIconContainerStackView.isUserInteractionEnabled = true
        closeIconContainerStackView.addGestureRecognizer(onTapCloseIconGesture)
        
        let onTapUsernameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapToUserProfile))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(onTapUsernameLabelGesture)
        
        let onTapProfileImageGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapToUserProfile))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(onTapProfileImageGesture)
    }

    func configure(_ item: NotificationSuggestionAccountItem) {
        self.item = item
        usernameLabel.text = item.name
        profileImageView.loadProfileImage(from: item.photo)
        verifiedIconImageView.isHidden = !item.isVerified
        firstMutualUserProfileImageView.isHidden = item.firstPhoto.isEmpty
        
        if !item.firstPhoto.isEmpty {
            //firstMutualUserProfileImageView.loadProfileImage(from: item.photo)
            firstMutualUserProfileImageView.loadProfileImage(from: item.firstPhoto)
            subtitleLabel.text = "Berteman dengan"
        } else {
            subtitleLabel.text = "yang mungkin kamu kenal."
        }
        
        setFollowButtonState(by: item)
    }
    
    func configureForActivityDetail(_ item: NotificationSuggestionAccountItem) {
        self.item = item
        usernameLabel.text = item.name
        profileImageView.loadProfileImage(from: item.photo)
        verifiedIconImageView.isHidden = !item.isVerified
        firstMutualUserProfileImageView.isHidden = true
        subtitleLabel.text = item.username
        setFollowButtonState(by: item)
    }
    
    private func setFollowButtonState(by item: NotificationSuggestionAccountItem) {
        switch (item.isFollowed, item.isFollow) {
        case (true, true):
            followTitleLabel.text = "Message"
            followTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
            followTitleLabel.backgroundColor = UIColor(hexString: "#F9F9F9")
            followTitleLabel.textColor = UIColor(hexString: "#4A4A4A")
        case (false, true):
            followTitleLabel.text = "Following"
            followTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
            followTitleLabel.backgroundColor = UIColor(hexString: "#F9F9F9")
            followTitleLabel.textColor = UIColor(hexString: "#4A4A4A")
        case (true, false):
            followTitleLabel.text = "Follow Back"
            followTitleLabel.font = .systemFont(ofSize: 12, weight: .bold)
            followTitleLabel.backgroundColor = UIColor(hexString: "#FF4265")
            followTitleLabel.textColor = .white
        case (false, false):
            followTitleLabel.text = "Follow"
            followTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
            followTitleLabel.backgroundColor = UIColor(hexString: "#FF4265")
            followTitleLabel.textColor = .white
        }
    }
    
    @objc func handleOnTapCloseButton() {
        handleTapCloseButton?()
    }
    
    @objc func handleOnTapFollowButton() {
        guard let item = item else { return }
        
        switch (item.isFollowed, item.isFollow) {
        case (true, true):
            delegate?.didClickMessage(by: item.id)
        case (false, true):
            delegate?.didClickFollowing(by: item.id)
        case (true, false):
            delegate?.didClickFollow(by: item.id)
        case (false, false):
            delegate?.didClickFollow(by: item.id)
        }
    }
    
    @objc private func handleOnTapToUserProfile() {
        guard let item = item else { return }
        delegate?.navigateToUserProfile(by: item.id)
    }
}
