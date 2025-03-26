//
//  UserProfileHeaderView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared
import Kingfisher

protocol UserProfileHeaderDelegate: AnyObject {
	func showOption()
	func goToShop()
	func setProfile(id: String, type: String)
	func refresh()
	func followers()
	func followings()
	func followButton(id:String, isFollowed: Bool)
    func onTapProfileImage(image: UIImage?)
}

class UserProfileHeaderView: UICollectionReusableView {
	
	weak var delegate: UserProfileHeaderDelegate?
	static let sectionCustomHeaderElementKind = "section-custom-header-element-kind"
	
	var item: Profile? = nil
    
	enum ViewTrait {
		static let padding: CGFloat = 16.0
		static let cellId: String = "cellId"
	}
	var bioLabelTopAnchorToUserImage: NSLayoutConstraint?
	var shopButtonTopAnchorToBioLabel: NSLayoutConstraint?
	var shopButtonTopAnchorToUserImage: NSLayoutConstraint?
    
    lazy var readStoryGradientLayer: CAGradientLayer = {
        let cTop    = UIColor(hexString: "#EA3BAC").cgColor
        let cBottom = UIColor(hexString: "#FF8000").cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [cTop, cBottom]
        gradientLayer.locations = [0, 1]
        gradientLayer.isHidden = true
        return gradientLayer
    }()
    
    lazy var userImageContainerView = UIView()

	lazy var userImageView: BadgedProfileImageView = {
		let imageView = BadgedProfileImageView()
        imageView.isUserInteractionEnabled = true
		return imageView
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handlePullToRequest), for: .valueChanged)
		return refresh
	}()
	
	let nameLabel: UILabel = UILabel(text: ".", font: .Roboto(.bold, size: 16), textColor: .white, textAlignment: .left, numberOfLines: 2)
	
	var usernameLabel: UILabel = UILabel(text: ".", font: .Roboto(size: 12), textColor: .white, textAlignment: .left, numberOfLines: 1)
	
	lazy var verifiedIconImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: String.get(.iconVerified)))
		imageView.contentMode = .scaleAspectFit
		imageView.isHidden = true
		return imageView
	}()
	
	let postingLabel : UILabel = UILabel(text: .get(.posting), font: .Roboto(.regular, size: 12), textColor: .gray, textAlignment: .left, numberOfLines: 1)
	let totalPostLabel: UILabel = UILabel(text: "0", font: .Roboto(.bold, size: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
	lazy var followerLabel : UILabel = UILabel(text: .get(.follower), font: .Roboto(.regular, size: 12), textColor: .gray, textAlignment: .left, numberOfLines: 1)
	
	lazy var iconsSocmedView: UserProfileIconsView =  {
		let view = UserProfileIconsView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	lazy var totalFollowerLabel: UILabel = UILabel(text: "0", font: .Roboto(.bold, size: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
	
	lazy var followingLabel : UILabel = UILabel(text: .get(.following), font: .Roboto(.regular, size: 12), textColor: .gray, textAlignment: .left, numberOfLines: 1)
	
	lazy var totalFollowingLabel: UILabel = UILabel(text: "0", font: .Roboto(.bold, size: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
	
	lazy var optionIconButton: UIButton = {
		let imageView = UIButton(type: .system)
		imageView.setImage(UIImage(named: String.get(.iconEllipsis)), for: .normal)
		imageView.backgroundColor = .white
		return imageView
	}()
	
	var bioLabel: UILabel = UILabel(text: ".", font: .Roboto(.regular, size: 13), textColor:.contentGrey, textAlignment: .left, numberOfLines: 0)
	
	lazy var iconShopButton: UIButton = {
		let button = UIButton(title: .get(.shop), titleColor: .gradientStoryOne, font: .Roboto(.medium, size: 14), backgroundColor: .whiteSnow)
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(self.goToShop), for: .touchUpInside)
        button.image(String.get(.icshopnew))
		button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 16)
        button.tintColor = .gradientStoryOne
		return button
	}()
	
	lazy var messageButton: UIButton = {
		let button = UIButton(title: .get(.message), titleColor: .contentGrey, font: .Roboto(.medium, size: 14), backgroundColor: .whiteSnow)
		button.layer.cornerRadius = 8
        let img = UIImage(named: .get(.iconSendMessage))!.withRenderingMode(.alwaysOriginal)
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 16)
        button.setImage(img)
		return button
	}()
	
	lazy var redDot : UIView = {
		let view = UIView()
		view.layer.cornerRadius = 2.5
		view.backgroundColor = UIColor.red
        view.isHidden = true
		return view
	}()
    
    lazy var redDotMessage : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.backgroundColor = UIColor.red
        view.isHidden = true
        return view
    }()
	
    lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconShopButton, messageButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 8
        return stack
    }()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[userImageContainerView, nameLabel, usernameLabel, verifiedIconImageView, optionIconButton, bioLabel, iconsSocmedView, buttonStackView].forEach {
			addSubview($0)
		}
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        userImageView.addGestureRecognizer(gestureRecognizer)
        
        userImageContainerView.addSubview(userImageView)
        
		let postingCountView = UIStackView(arrangedSubviews: [postingLabel, totalPostLabel])
		postingCountView.axis = .vertical
        postingCountView.backgroundColor = .white
        postingLabel.backgroundColor = .white
        totalPostLabel.backgroundColor = .white
        
		let followerCountView = UIStackView(arrangedSubviews: [followerLabel, totalFollowerLabel])
		followerCountView.axis = .vertical
        followerCountView.backgroundColor = .white
        followerLabel.backgroundColor = .white
        totalFollowerLabel.backgroundColor = .white
		let gestureFollower = UITapGestureRecognizer(target: self, action: #selector(handleFollowers))
		followerCountView.isUserInteractionEnabled = true
		followerCountView.addGestureRecognizer(gestureFollower)
		
		let followingCountView = UIStackView(arrangedSubviews: [followingLabel, totalFollowingLabel])
		followingCountView.axis = .vertical
        followingCountView.backgroundColor = .white
        followingLabel.backgroundColor = .white
        totalFollowingLabel.backgroundColor = .white
		let gestureFollowing = UITapGestureRecognizer(target: self, action: #selector(handleFollowing))
		followingCountView.isUserInteractionEnabled = true
		followingCountView.addGestureRecognizer(gestureFollowing)
        
        userImageContainerView.isUserInteractionEnabled = true
        userImageContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleStory)))
		
        userImageContainerView.anchor(top: self.safeAreaLayoutGuide.topAnchor, left: self.leftAnchor, paddingTop: 16, paddingLeft: 16, width: 92, height: 92)
        
        userImageView.fillSuperview(padding: UIEdgeInsets(horizontal: 0, vertical: 0))
		
		nameLabel.anchor(top: self.safeAreaLayoutGuide.topAnchor, left: userImageContainerView.rightAnchor, paddingTop: 16, paddingLeft: 20, paddingBottom: 0, paddingRight: 0)
        nameLabel.backgroundColor = .white
		
		usernameLabel.anchor(top: nameLabel.bottomAnchor, left: userImageContainerView.rightAnchor, paddingTop: 2, paddingLeft: 20, height: 20)
		
		verifiedIconImageView.anchor(top: usernameLabel.topAnchor, left: usernameLabel.rightAnchor, bottom: usernameLabel.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, width: 12)
		let verificationImageHeightConstrain = verifiedIconImageView.heightAnchor.constraint(equalToConstant: 12)
		verificationImageHeightConstrain.isActive = true
		verificationImageHeightConstrain.priority = UILayoutPriority(rawValue: 750)
		
		optionIconButton.anchor(top: self.safeAreaLayoutGuide.topAnchor, left: nameLabel.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 32, height: 32)
		
		optionIconButton.addSubview(redDot)
		redDot.anchor(top: optionIconButton.topAnchor, right: optionIconButton.rightAnchor, width: 5, height: 5)
        
        messageButton.addSubview(redDotMessage)
        redDotMessage.anchor( width: 5, height: 5)
        redDotMessage.centerXAnchor.constraint(equalTo: messageButton.centerXAnchor, constant: 50).isActive = true
        redDotMessage.centerYTo(messageButton.centerYAnchor)
		
		let stackView = UIStackView(arrangedSubviews: [postingCountView, followerCountView, followingCountView])
		stackView.axis = .horizontal
		stackView.distribution = .equalSpacing
		stackView.spacing = 24
		
		self.addSubview(stackView)
		
		stackView.anchor(top: usernameLabel.bottomAnchor, left: userImageContainerView.rightAnchor, bottom: nil, paddingTop: 12, paddingLeft: 20, paddingBottom: 0, paddingRight: 24)
		
		bioLabel.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 29)
        bioLabel.backgroundColor = .white
		bioLabelTopAnchorToUserImage = bioLabel.topAnchor.constraint(equalTo: userImageContainerView.bottomAnchor, constant: 16)
		bioLabelTopAnchorToUserImage?.isActive = true
		
		iconsSocmedView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, height: 40)
		shopButtonTopAnchorToBioLabel = iconsSocmedView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 16)
		shopButtonTopAnchorToBioLabel?.isActive = false
		
		shopButtonTopAnchorToUserImage = iconsSocmedView.topAnchor.constraint(equalTo: userImageContainerView.bottomAnchor, constant: 16)
		shopButtonTopAnchorToUserImage?.isActive = true
		
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: iconsSocmedView.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40),
        ])
        
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupHeaderConstraintPriority(bio: String?) {
		if bio.isNilOrEmpty {
			bioLabelTopAnchorToUserImage?.isActive = false
			shopButtonTopAnchorToUserImage?.isActive = true
			shopButtonTopAnchorToBioLabel?.isActive = false
			self.bioLabel.isHidden = true
		} else {
			shopButtonTopAnchorToUserImage?.isActive = false
			bioLabelTopAnchorToUserImage?.isActive = true
			shopButtonTopAnchorToBioLabel?.isActive = true
			self.bioLabel.isHidden = false
			self.bioLabel.text = bio
		}
		bioLabel.setNeedsLayout()
		bioLabel.layoutSubviews()
	}
	
	func configure(viewModel: Profile) {
		self.item = viewModel
		self.nameLabel.textColor = .black
		self.nameLabel.text = viewModel.name
		self.usernameLabel.textColor = .black
		self.usernameLabel.text = "@\(viewModel.username ?? "")"
        usernameLabel.backgroundColor = .white

        let profilePhotoURL = URL(string: viewModel.photo ?? "")
        self.userImageView.userImageView.kf.indicatorType = .activity
        self.userImageView.userImageView.kf.setImage(with: profilePhotoURL, placeholder: UIImage.emptyProfilePhoto)
        self.userImageView.rank = viewModel.donationBadge?.globalRank ?? 0
        self.userImageView.shouldShowBadge = viewModel.donationBadge?.isShowBadge == true
        
        let badgeURL = URL(string: viewModel.donationBadge?.url ?? "")
        self.userImageView.badgeImageView.kf.indicatorType = .activity
        self.userImageView.badgeImageView.kf.setImage(with: badgeURL)
        
		self.setupHeaderConstraintPriority(bio: viewModel.bio ?? "")
		self.optionIconButton.isHidden = viewModel.id != getIdUser() ? true : false
		self.verifiedIconImageView.isHidden = viewModel.isVerified == false || viewModel.isVerified == nil
		
		if viewModel.socialMedias?.isEmpty == false {
			viewModel.socialMedias?.forEach {
				if $0.socialMediaType?.contains(SocialMediaType.instagram.rawValue) ?? false {
					if $0.urlSocialMedia?.isEmpty == false {
						iconsSocmedView.icons[0].isUserInteractionEnabled = true
						iconsSocmedView.icons[0] = UIImageView(image: UIImage(named: .get(.iconActiveInstagram))!)
					} else {
						iconsSocmedView.icons[0].isUserInteractionEnabled = false
						iconsSocmedView.icons[0] = UIImageView(image: UIImage(named: .get(.iconNonActiveInstagram))!)
					}
				} else if ($0.socialMediaType?.contains(SocialMediaType.tiktok.rawValue) ?? false) {
					if $0.urlSocialMedia?.isEmpty == false {
						iconsSocmedView.icons[1].isUserInteractionEnabled = true
						iconsSocmedView.icons[1] = UIImageView(image: UIImage(named: .get(.iconActiveTiktok))!)
						
					} else {
						iconsSocmedView.icons[1].isUserInteractionEnabled = true
						iconsSocmedView.icons[1] = UIImageView(image: UIImage(named: .get(.iconNonActiveTiktok))!)
					}
					
				} else if ($0.socialMediaType?.contains(SocialMediaType.wikipedia.rawValue) ?? false) {
					if $0.urlSocialMedia?.isEmpty == false {
						
						iconsSocmedView.icons[2].isUserInteractionEnabled = true
						iconsSocmedView.icons[2] = UIImageView(image: UIImage(named: .get(.iconActiveWikipedia))!)
						
					} else {
						iconsSocmedView.icons[2].isUserInteractionEnabled = false
						iconsSocmedView.icons[2] = UIImageView(image: UIImage(named: .get(.iconNonActiveWikipedia))!)
					}
					
				} else if ($0.socialMediaType?.contains(SocialMediaType.facebook.rawValue) ?? false) {
					if $0.urlSocialMedia?.isEmpty == false {
//						self.delegate?.routeSocmed(url: viewModel.socialMedias?[0].urlSocialMedia ?? "")
						iconsSocmedView.icons[3].isUserInteractionEnabled = true
						iconsSocmedView.icons[3] = UIImageView(image: UIImage(named: .get(.iconActiveFacebook))!)
					} else {
						iconsSocmedView.icons[3].isUserInteractionEnabled = false
						iconsSocmedView.icons[3] = UIImageView(image: UIImage(named: .get(.iconNonActiveFacebook))!)
					}
					
				} else if ($0.socialMediaType?.contains(SocialMediaType.twitter.rawValue) ?? false) {
					if $0.urlSocialMedia?.isEmpty == false {
//						delegate?.routeSocmed(url: viewModel.socialMedias?[4].urlSocialMedia ?? "")
						iconsSocmedView.icons[4].isUserInteractionEnabled = true
						iconsSocmedView.icons[4] = UIImageView(image: UIImage(named: .get(.iconActiveTwitter))!)
					} else {
						iconsSocmedView.icons[4].isUserInteractionEnabled = false
						iconsSocmedView.icons[4] = UIImageView(image: UIImage(named: .get(.iconNonActiveTwitter))!)
					}
				}
			}
		}
	}
	
	func configureFollowers(value: TotalFollow) {
		self.totalFollowerLabel.text = String(describing: value.data ?? 0)
		self.setNeedsDisplay()
	}
	
	func configureFollowing(value: TotalFollow) {
		self.totalFollowingLabel.text = String(describing: value.data ?? 0)
		self.setNeedsDisplay()
	}
	
	func configurePost(value: TotalFollow) {
		self.totalPostLabel.text = String(describing: value.data ?? 0)
		self.setNeedsDisplay()
	}
	
	@objc func goToShop() {
		delegate?.goToShop()
	}
	
	@objc func handlePullToRequest() {
		self.delegate?.refresh()
	}
	
	@objc func handleFollowers() {
		self.delegate?.followers()
	}
	
	@objc func handleFollowing() {
		self.delegate?.followings()
	}
    
    @objc private func profileImageTapped() {
        delegate?.onTapProfileImage(image: userImageView.userImageView.image)
    }
    
    @objc func handleStory() {}
	
//	@objc func handleMessageButton() {
//		guard let profileId = item?.id, let isFollowed = item?.isFollow else {return}
//
//		isFollowing.toggle()
//		self.delegate?.followButton(id: profileId, isFollowed: isFollowing)
//        gotToMessageView?()
//	}
	
	func setupCount(count: TotalCountProfile) {
		totalFollowingLabel.text = String(count.followingCount)
		totalPostLabel.text = String(count.postCount)
		totalFollowerLabel.text = String(count.followerCount)
	}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        readStoryGradientLayer.frame = self.userImageContainerView.bounds
        readStoryGradientLayer.cornerRadius = 18
        userImageContainerView.layer.insertSublayer(readStoryGradientLayer, at: 0)
    }
    
    func setReadStory(_ read: Bool) {
        readStoryGradientLayer.isHidden = read
    }
}
