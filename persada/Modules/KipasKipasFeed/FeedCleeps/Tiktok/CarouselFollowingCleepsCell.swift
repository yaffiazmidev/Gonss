//
//  CarouselFollowingCleepsCell.swift
//  FeedCleeps
//
//  Created by DENAZMI on 30/11/22.
//

import UIKit
import KipasKipasShared

protocol CarouselFollowingCleepsCellDelegate {
    func didClickCloseButton()
    func didClickFollowButton()
}

class CarouselFollowingCleepsCell: FSPagerViewCell {

    @IBOutlet weak var followButton: PrimaryButton! {
        didSet { followButton.titleFont = .Roboto(.medium, size: 12) }
    }
    @IBOutlet weak var verifiedIcon: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var userPostImage1: UIImageView!
    @IBOutlet weak var userPostImage2: UIImageView!
    @IBOutlet weak var userPostImage3: UIImageView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var closeIconStackView: UIStackView!
    
    var delegate: CarouselFollowingCleepsCellDelegate?
    
    var handleClickCloseButton: (() -> Void)?
    var handleClickFollowButton: (() -> Void)?
    var handleTapUserProfile: (() -> Void)?
    var handleTapUserPostImage: ((String?) -> Void)?
    
    var user: FollowingSuggestionContent? {
        didSet {
            let isFollow = user?.account?.isFollow ?? false
            followButton.backgroundColor = isFollow ? .whiteSnow : .primary
            followButton.setTitle(isFollow ? "Following" : "Follow" , for: .normal)
            followButton.setTitleColor(isFollow ? .contentGrey : .white, for: .normal)
            usernameLabel.text = user?.account?.name ?? "-"
            userProfileImage.loadImage(at: user?.account?.photo ?? "")
            setupUserPost(post: user?.feeds ?? [])
            verifiedIcon.isHidden = !(user?.account?.isVerified ?? false)
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
                
        let onTapCloseIconGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCloseIcon))
        closeIconStackView.addGestureRecognizer(onTapCloseIconGesture)
        
        let onTapUserProfileImageGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserProfileImage))
        userProfileImage.isUserInteractionEnabled = true
        userProfileImage.addGestureRecognizer(onTapUserProfileImageGesture)
        
        let onTapUsernameGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserProfileImage))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(onTapUsernameGesture)
        
        let onTapuserPostImage1Gesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserPostImage1))
        userPostImage1.isUserInteractionEnabled = true
        userPostImage1.addGestureRecognizer(onTapuserPostImage1Gesture)
        
        let onTapuserPostImage2Gesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserPostImage2))
        userPostImage2.isUserInteractionEnabled = true
        userPostImage2.addGestureRecognizer(onTapuserPostImage2Gesture)
        
        let onTapuserPostImage3Gesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserPostImage3))
        userPostImage3.isUserInteractionEnabled = true
        userPostImage3.addGestureRecognizer(onTapuserPostImage3Gesture)
    }
    
    private func setupUserPost(post: [Feed]) {
        let userCount = user?.feeds?.count ?? 0
        
        userPostImage1.isHidden = userCount > 0 ? false : true
        userPostImage2.isHidden = userCount > 1 ? false : true
        userPostImage3.isHidden = userCount > 2 ? false : true

        if userCount > 0 {
            guard let thumbnail = user?.feeds?[0].post?.medias?[0].thumbnail?.medium else {
                userPostImage1.isHidden = true
                return
            }
            userPostImage1.loadImageWithoutOSS(at: thumbnail)
        }
        
        if userCount > 1 {
            guard let thumbnail = user?.feeds?[1].post?.medias?[0].thumbnail?.medium else {
                userPostImage2.isHidden = true
                return
            }
            userPostImage2.loadImageWithoutOSS(at: thumbnail)
        }
        
        if userCount > 2 {
            guard let thumbnail = user?.feeds?[2].post?.medias?[0].thumbnail?.medium else {
                userPostImage3.isHidden = true
                return
            }
            userPostImage3.loadImageWithoutOSS(at: thumbnail)
        }
    }
    
    @objc func didTapUserPostImage1() {
        handleTapUserPostImage?(user?.feeds?[0].id)
    }
    
    @objc func didTapUserPostImage2() {
        handleTapUserPostImage?(user?.feeds?[1].id)
    }
    
    @objc func didTapUserPostImage3() {
        handleTapUserPostImage?(user?.feeds?[2].id)
    }
    
    @objc func didTapCloseIcon() {
        closeIconStackView.isUserInteractionEnabled = false
        handleClickCloseButton?()
    }
    
    @objc func didTapUserProfileImage() {
        handleTapUserProfile?()
    }
    
    @IBAction func didClickFollowButton(_ sender: Any) {
        handleClickFollowButton?()
        print("sebelum \(user?.account?.isFollow ?? false)")
        let isFollow = user?.account?.isFollow ?? false
        user?.account?.isFollow = !isFollow
        followButton.backgroundColor = isFollow ? .primary : .gainsboro
        followButton.setTitle(isFollow ? "Follow" : "Following", for: .normal)
        print("sesudah \(user?.account?.isFollow ?? false)")
    }
}
