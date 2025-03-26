//
//  AnotherUserProfileHeaderView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared
import Kingfisher

class AnotherUserProfileHeaderView: UICollectionReusableView {
	
	weak var delegate: UserProfileHeaderDelegate?
    var changeReportAndBlock: (() -> Void)?
    var changeBukaBlock: ((String) -> Void)?
	static let sectionCustomHeaderElementKind = "section-custom-header-element-kind"
	
	var item: Profile? = nil
	var isFollowing: Bool = false {
		didSet {
			configureFollowButton()
		}
	}
	
	enum ViewTrait {
		static let padding: CGFloat = 16.0
		static let cellId: String = "cellId"
	}
	var bioLabelTopAnchorToUserImage: NSLayoutConstraint?
	var shopButtonTopAnchorToBioLabel: NSLayoutConstraint?
	var shopButtonTopAnchorToUserImage: NSLayoutConstraint?
	
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
	let totalPostLabel: UILabel = UILabel(text: "", font: .Roboto(.bold, size: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
	lazy var followerLabel : UILabel = UILabel(text: .get(.follower), font: .Roboto(.regular, size: 12), textColor: .gray, textAlignment: .left, numberOfLines: 1)
	
	lazy var iconsSocmedView: UserProfileIconsView =  {
		let view = UserProfileIconsView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	lazy var totalFollowerLabel: UILabel = UILabel(text: "", font: .Roboto(.bold, size: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
	
	lazy var followingLabel : UILabel = UILabel(text: .get(.following), font: .Roboto(.regular, size: 12), textColor: .gray, textAlignment: .left, numberOfLines: 1)
	
	lazy var totalFollowingLabel: UILabel = UILabel(text: "", font: .Roboto(.bold, size: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
	
	lazy var optionIconButton: UIButton = {
		let imageView = UIButton(type: .system)
		imageView.setImage(UIImage(named: String.get(.iconEllipsis)), for: .normal)
		imageView.backgroundColor = .white
		return imageView
	}()
	
	var bioLabel: UILabel = UILabel(text: "", font: .Roboto(.regular, size: 13), textColor:.contentGrey, textAlignment: .left, numberOfLines: 5)
	
	lazy var iconShopButton: UIButton = {
		let button = UIButton(title: .get(.shop), titleColor: .gradientStoryOne, font: .Roboto(.medium, size: 14), backgroundColor: .whiteSnow)
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(self.goToShop), for: .touchUpInside)
		button.image(String.get(.icshopnew))
		button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 16)
        button.tintColor = .gradientStoryOne
		return button
	}()
    
    lazy var bukaBlockerButton: UIButton = {
        let button = UIButton(title: .get(.bukaBlocker), titleColor: .gradientStoryOne, font: .Roboto(.medium, size: 12), backgroundColor: .whiteSnow)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleBukaBlock), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
	
	lazy var followButton: UIButton = {
		let button = UIButton(title: .get(.follow), titleColor: .white, font: .Roboto(.medium, size: 14), backgroundColor: .gradientStoryOne)
		button.layer.cornerRadius = 8
		return button
	}()
	
	lazy var redDot : UIView = {
		let view = UIView()
		view.layer.cornerRadius = 2.5
		view.backgroundColor = UIColor.red
        view.isHidden = true
		return view
	}()
    
    lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconShopButton, followButton, bukaBlockerButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 8
        return stack
    }()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[userImageView, nameLabel, usernameLabel, verifiedIconImageView, optionIconButton, bioLabel, iconsSocmedView, buttonStackView].forEach {
			addSubview($0)
		}
        
        if item?.id ?? "" != getIdUser() {
            optionIconButton.addTarget(self, action: #selector(handleReportAndBlock), for: .touchUpInside)
        } else {
            optionIconButton.addTarget(self, action: #selector(handleOptionButton), for: .touchUpInside)
        }
		
		let postingCountView = UIStackView(arrangedSubviews: [postingLabel, totalPostLabel])
		postingCountView.axis = .vertical
		
		let followerCountView = UIStackView(arrangedSubviews: [followerLabel, totalFollowerLabel])
		followerCountView.axis = .vertical
		let gestureFollower = UITapGestureRecognizer(target: self, action: #selector(handleFollowers))
		followerCountView.isUserInteractionEnabled = true
		followerCountView.addGestureRecognizer(gestureFollower)
		
		let followingCountView = UIStackView(arrangedSubviews: [followingLabel, totalFollowingLabel])
		followingCountView.axis = .vertical
		let gestureFollowing = UITapGestureRecognizer(target: self, action: #selector(handleFollowing))
		followingCountView.isUserInteractionEnabled = true
		followingCountView.addGestureRecognizer(gestureFollowing)
		
		userImageView.anchor(top: self.safeAreaLayoutGuide.topAnchor, left: self.leftAnchor, paddingTop: 16, paddingLeft: 16, width: 92, height: 92)
		
		nameLabel.anchor(top: userImageView.topAnchor, left: userImageView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0)
		
		usernameLabel.anchor(top: nameLabel.bottomAnchor, left: userImageView.rightAnchor, paddingTop: 2, paddingLeft: 20, height: 20)
		
		verifiedIconImageView.anchor(top: usernameLabel.topAnchor, left: usernameLabel.rightAnchor, bottom: usernameLabel.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, width: 12)
		let verificationImageHeightConstrain = verifiedIconImageView.heightAnchor.constraint(equalToConstant: 12)
		verificationImageHeightConstrain.isActive = true
		verificationImageHeightConstrain.priority = UILayoutPriority(rawValue: 750)
		
		optionIconButton.anchor(top: self.safeAreaLayoutGuide.topAnchor, left: nameLabel.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 32, height: 32)
		
		optionIconButton.addSubview(redDot)
		redDot.anchor(top: optionIconButton.topAnchor, right: optionIconButton.rightAnchor, width: 5, height: 5)
		
		let stackView = UIStackView(arrangedSubviews: [postingCountView, followerCountView, followingCountView])
		stackView.axis = .horizontal
		stackView.distribution = .equalSpacing
		stackView.spacing = 24
		
		self.addSubview(stackView)
		
		stackView.anchor(top: usernameLabel.bottomAnchor, left: userImageView.rightAnchor, bottom: nil, paddingTop: 12, paddingLeft: 20, paddingBottom: 0, paddingRight: 24)
		
		bioLabel.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 29)
		bioLabelTopAnchorToUserImage = bioLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 16)
		bioLabelTopAnchorToUserImage?.isActive = true
		
		iconsSocmedView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, height: 40)
		shopButtonTopAnchorToBioLabel = iconsSocmedView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 16)
		shopButtonTopAnchorToBioLabel?.isActive = false
		
		shopButtonTopAnchorToUserImage = iconsSocmedView.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 16)
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
		self.isFollowing = item?.isFollow ?? false
		self.nameLabel.textColor = .black
		self.nameLabel.text = viewModel.name
		self.usernameLabel.textColor = .black
		self.usernameLabel.text = "@\(viewModel.username ?? "")"
		
        let profilePhotoURL = URL(string: viewModel.photo ?? "")
        self.userImageView.userImageView.kf.indicatorType = .activity
        self.userImageView.userImageView.kf.setImage(with: profilePhotoURL, placeholder: UIImage.emptyProfilePhoto)
        self.userImageView.rank = viewModel.donationBadge?.globalRank ?? 0
        self.userImageView.shouldShowBadge = viewModel.donationBadge?.isShowBadge == true
        
        let badgeURL = URL(string: viewModel.donationBadge?.url ?? "")
        self.userImageView.badgeImageView.kf.indicatorType = .activity
        self.userImageView.badgeImageView.kf.setImage(with: badgeURL)
		
		self.setupHeaderConstraintPriority(bio: viewModel.bio ?? "")
        let usersBlock = UserDefaultBlockUser().getUsersId() ?? []
        let externalId = item?.id ?? ""
//		self.optionIconButton.isHidden = viewModel.id != getIdUser() ? true : false
		self.configureFollowButton()
		self.verifiedIconImageView.isHidden = viewModel.isVerified == false
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
//                        self.delegate?.routeSocmed(url: viewModel.socialMedias?[0].urlSocialMedia ?? "")
                        iconsSocmedView.icons[3].isUserInteractionEnabled = true
                        iconsSocmedView.icons[3] = UIImageView(image: UIImage(named: .get(.iconActiveFacebook))!)
                    } else {
                        iconsSocmedView.icons[3].isUserInteractionEnabled = false
                        iconsSocmedView.icons[3] = UIImageView(image: UIImage(named: .get(.iconNonActiveFacebook))!)
                    }
                    
                } else if ($0.socialMediaType?.contains(SocialMediaType.twitter.rawValue) ?? false) {
                    if $0.urlSocialMedia?.isEmpty == false {
//                        delegate?.routeSocmed(url: viewModel.socialMedias?[4].urlSocialMedia ?? "")
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
    
    func hideBukaBlockButton(hide: Bool) {
        iconShopButton.isHidden = !hide
        followButton.isHidden = !hide
        bukaBlockerButton.isHidden = hide
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
	
	private func configureFollowButton() {
		if isFollowing {
			followButton.setTitle(.get(.following), for: .normal)
			followButton.backgroundColor = .whiteSnow
			followButton.setTitleColor(.grey, for: .normal)
		} else {
			followButton.setTitle(.get(.follow), for: .normal)
			followButton.backgroundColor = .gradientStoryOne
			followButton.setTitleColor(.white, for: .normal)
		}
	}
	
	@objc func handleOptionButton() {
		self.delegate?.showOption()
	}
    
    @objc
    func handleBukaBlock() {
        hideBukaBlockButton(hide: true)
        
        if let id = item?.id {
            changeBukaBlock?(id)
        }
    }
    
    @objc
    func handleReportAndBlock() {
        changeReportAndBlock?()
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
	
	@objc func handleFollowButton() {
		guard let profileId = item?.id, let isFollowed = item?.isFollow else {return}
		
		isFollowing.toggle()
		self.delegate?.followButton(id: profileId, isFollowed: isFollowing)
	}
	
	func setupCount(count: TotalCountProfile) {
		totalFollowingLabel.text = String(count.followingCount)
		totalPostLabel.text = String(count.postCount)
		totalFollowerLabel.text = String(count.followerCount)
	}
}

