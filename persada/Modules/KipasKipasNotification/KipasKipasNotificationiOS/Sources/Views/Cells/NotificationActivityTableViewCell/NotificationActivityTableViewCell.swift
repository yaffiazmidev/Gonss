//
//  NotificationActivityTableViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 20/03/24.
//

import UIKit
import KipasKipasNotification

class NotificationActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var verifiedIconImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var contentThumbnailImageView: UIImageView!
    @IBOutlet weak var isReadDotView: UIView!
    @IBOutlet weak var actionTypeIconImageView: UIImageView!
    @IBOutlet weak var firstMutualUserImageView: UIImageView!
    @IBOutlet weak var secondMutualUserImageView: UIImageView!
    
    var item: NotificationActivitiesItem?
    var handleNavigateToUserProfile: ((String) -> Void)?
    var handleNavigateToFeed: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        verifiedIconImageView.image = UIImage.iconVerified
        secondMutualUserImageView.layer.borderWidth = 2
        secondMutualUserImageView.layer.borderColor = UIColor.white.cgColor
        
        let onTapUsernameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapToUserProfile))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(onTapUsernameLabelGesture)
        
        let onTapProfileImageGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapToUserProfile))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(onTapProfileImageGesture)
        
        let onTapContentThumbnailImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapContentThumbnail))
        contentThumbnailImageView.isUserInteractionEnabled = true
        contentThumbnailImageView.addGestureRecognizer(onTapContentThumbnailImageViewGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
        usernameLabel.text = nil
        dateLabel.text = nil
        subtitleLabel.text = nil
        handleNavigateToUserProfile = nil
        handleNavigateToFeed = nil
        profileImageView.cancelLoad()
        firstMutualUserImageView.cancelLoad()
        secondMutualUserImageView.cancelLoad()
        contentThumbnailImageView.cancelLoad()
    }

    func configure(with item: NotificationActivitiesItem) {
        self.item = item
        backgroundColor = item.isRead ? .white : UIColor(hexString: "F3FDFE")
        isReadDotView.backgroundColor = item.isRead ? .white : UIColor(hexString: "20D5EC")
        
        usernameLabel.text = item.actionAccountName
        dateLabel.text = item.modifiedAt.timeAgoDisplay()
        contentThumbnailImageView.isHidden = item.thumbnailUrl.isEmpty
//        contentThumbnailImageView.loadImage(from: item.thumbnailUrl, placeholder: UIImage.emptyProfilePhoto)
        contentThumbnailImageView.loadImageWithOSS(from: item.thumbnailUrl, size: .w240)
        
        profileImageView.isHidden = true
        firstMutualUserImageView.isHidden = true
        secondMutualUserImageView.isHidden = true
        
        if item.actionType == "like" {
            
            usernameLabel.isUserInteractionEnabled = false
            
            var targetType: String {
                if item.targetType == "comment" || item.targetType == "commentSub" {
                    return "komentar"
                } else if item.targetType == "feed" {
                    return "post"
                }
                return ""
            }
            
            if (item.other > 0) {
                
                let usernameText = "\(item.firstName), \(item.secondName) ".makeMutableAttributedString(font: .systemFont(ofSize: 15, weight: .medium))
                usernameText.append("and ".makeMutableAttributedString(color: UIColor(hexString: "#777777")))
                usernameText.append("\(item.other.formatViews()) others".makeMutableAttributedString(font: .systemFont(ofSize: 15, weight: .medium)))
                
                firstMutualUserImageView.isHidden = false
                secondMutualUserImageView.isHidden = false
                firstMutualUserImageView.loadProfileImage(from: item.firstPhoto, size: .w100)
                secondMutualUserImageView.loadProfileImage(from: item.secondPhoto, size: .w100)
                
                usernameLabel.attributedText = usernameText
                subtitleLabel.text = "menyukai \(targetType) kamu"
                actionTypeIconImageView.image = UIImage.iconLikeFillPink
            } else if (item.secondName != "") {
                
                let usernameText = "\(item.firstName) ".makeMutableAttributedString(font: .systemFont(ofSize: 15, weight: .medium))
                usernameText.append("and ".makeMutableAttributedString(color: UIColor(hexString: "#777777")))
                usernameText.append("\(item.secondName)".makeMutableAttributedString(font: .systemFont(ofSize: 15, weight: .medium)))
                
                firstMutualUserImageView.isHidden = false
                secondMutualUserImageView.isHidden = false
                firstMutualUserImageView.loadProfileImage(from: item.firstPhoto, size: .w100)
                secondMutualUserImageView.loadProfileImage(from: item.secondPhoto, size: .w100)

                usernameLabel.attributedText = usernameText
                subtitleLabel.text = "menyukai \(targetType) kamu"
                actionTypeIconImageView.image = UIImage.iconLikeFillPink
            } else {
                profileImageView.isHidden = false
                profileImageView.loadProfileImage(from: item.firstPhoto, size: .w100)
                usernameLabel.isUserInteractionEnabled = true
                usernameLabel.text = item.firstName.isEmpty ? "-" : "\(item.firstName)"
                subtitleLabel.text = "menyukai \(targetType) kamu"
                actionTypeIconImageView.image = UIImage.iconLikeFillPink
            }
            
        } else if item.actionType == "comment" || item.actionType == "commentSub" {
            profileImageView.isHidden = false
            profileImageView.loadProfileImage(from: item.actionAccountPhoto)
            subtitleLabel.text = "Berkomentar: \(item.value)"
            actionTypeIconImageView.image = UIImage.iconCommentFillBlue
        } else if item.actionType == "mention" {
            profileImageView.isHidden = false
            profileImageView.loadProfileImage(from: item.actionAccountPhoto)
            actionTypeIconImageView.image = UIImage.iconMentionFillYellow
            if item.targetType == "feed" {
                subtitleLabel.text = "menyebut kamu dalam postingan"
            } else {
                subtitleLabel.text = "menyebut kamu dalam komentar: \(item.value)"
            }
        }
    }
    
    @objc private func handleOnTapToUserProfile() {
        guard let item = item else { return }
        
        if item.actionType == "like" {
            handleNavigateToUserProfile?(item.firstId)
        } else if item.actionType == "comment" || item.actionType == "commentSub" {
            handleNavigateToUserProfile?(item.actionAccountId)
        } else if item.actionType == "mention" {
            handleNavigateToUserProfile?(item.actionAccountId)
        }
    }
    
    @objc private func handleOnTapContentThumbnail() {
        guard let item = item else { return }
        handleNavigateToFeed?(item.feedId)
    }
}

private extension String {
    
    func makeMutableAttributedString(font: UIFont = .systemFont(ofSize: 14, weight: .regular), color: UIColor = .black) -> NSMutableAttributedString {
        return NSMutableAttributedString(
            string: self,
            attributes: [
                NSAttributedString.Key.foregroundColor: color.cgColor,
                NSAttributedString.Key.font: font
            ]
        )
    }
    
    func makeAttributedString() -> NSAttributedString {
        return NSAttributedString(string: self)
    }
}
