//
//  NewFollowerTableViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 20/03/24.
//

import UIKit
import KipasKipasNotification

protocol NewFollowerTableViewCellDelegate: AnyObject {
    func didClickFollow(by id: String)
    func didClickFollowing(by id: String)
    func didClickMessage(by id: String)
    func navigateToUserProfile(by id: String)
}

class NewFollowerTableViewCell: UITableViewCell {

    @IBOutlet weak var verifiedIconImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    weak var delegate: NewFollowerTableViewCellDelegate?
    private var item: NotificationFollowersContent?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        verifiedIconImageView.image = UIImage.iconVerified
        
        let onTapFollowTitleLabelGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapFollowButton))
        followTitleLabel.isUserInteractionEnabled = true
        followTitleLabel.addGestureRecognizer(onTapFollowTitleLabelGesture)
        
        let onTapUsernameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapToUserProfile))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(onTapUsernameLabelGesture)
        
        let onTapProfileImageGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapToUserProfile))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(onTapProfileImageGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
        delegate = nil
        usernameLabel.text = nil
        dateLabel.text = nil
        profileImageView.cancelLoad()
    }
    
    func configure(with item: NotificationFollowersContent) {
        self.item = item
        usernameLabel.text = item.name
        profileImageView.loadProfileImage(from: item.photo)
        dateLabel.text = item.followedAt.timeAgoDisplay()
        verifiedIconImageView.isHidden = !item.isVerified
        
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
    
    @objc private func handleOnTapFollowButton() {
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
