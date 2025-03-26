//
//  NotificationSocialItemCell.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Kingfisher

class NotificationSocialItemCell: UITableViewCell {
	
	lazy var userImageView: UIImageView = {
		var image = UIImageView()
		image.layer.masksToBounds = false
        image.translatesAutoresizingMaskIntoConstraints = false
		image.backgroundColor = .white
		image.contentMode = .scaleAspectFill
		image.layer.cornerRadius = 25
		image.clipsToBounds = true
        image.accessibilityIdentifier = "userImageView"
		return image
	}()
	
	lazy var postImageView: UIImageView = {
		let image = UIImageView()
        image.layer.masksToBounds = false
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .white
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 8
        image.clipsToBounds = true
        image.accessibilityIdentifier = "postImageView"
		return image
	}()
	
	lazy var iconImageView: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
		image.backgroundColor = .primary
		image.layer.cornerRadius = 10
		image.image = #imageLiteral(resourceName: "iconHeart")
        image.accessibilityIdentifier = "iconImageView"
		return image
	}()
	
	lazy var titleLabel: UILabel = UILabel( font: .Roboto(.bold, size: 16), textColor: .black, textAlignment: .left, numberOfLines: 0)
	
    lazy var subtitleLabel: UILabel = {
        let label = UILabel( font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
	
    lazy var containerView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        view.backgroundColor = .primaryLowTint
        return view
    }()
    
    lazy var socialStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [userImageView, descStackView, postImageView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .top
        view.distribution = .fill
        view.spacing = 12
        return view
    }()

    
    lazy var descStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 1
        return view
    }()

    
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        layer.cornerRadius = 8
        selectionStyle = .none
		
        contentView.addSubview(containerView)
        
        containerView.addSubview(socialStackView)
        socialStackView.anchors.top.equal(containerView.anchors.top, constant: 10)
        socialStackView.anchors.leading.equal(containerView.anchors.leading, constant: 16)
        socialStackView.anchors.bottom.equal(containerView.anchors.bottom)
        socialStackView.anchors.trailing.equal(containerView.anchors.trailing, constant: -16)
        
        userImageView.anchors.width.equal(50)
        userImageView.anchors.height.equal(50)
        
        postImageView.anchors.width.equal(50)
        postImageView.anchors.height.equal(50)
        containerView.fillSuperview()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.postImageView.image = nil
    }
    
    func setUpCell(item: NotificationSocial?){
		
		var photo = "\(item?.actionAccount?.photo ?? "")"
        if item?.isRead == true {
            containerView.backgroundColor = .white
            titleLabel.backgroundColor = .white
            subtitleLabel.backgroundColor = .white
        } else {
            containerView.backgroundColor = UIColor(hexString: "#F6FBFF")
            titleLabel.backgroundColor = UIColor(hexString: "#F6FBFF")
            subtitleLabel.backgroundColor = UIColor(hexString: "#F6FBFF")
        }
        
        if item?.actionType == "unlock_badge" {
            titleLabel.text = "Badge Baru Terbuka "
        } else if item?.actionType == "update_badge" {
            titleLabel.text = "Perubahan Ketentuan Badge"
        } else {
            titleLabel.text = item?.actionAccount?.username
            postImageView.loadImage(at: item?.thumbnailPhoto ?? "")
            userImageView.kf.indicatorType = .activity
            userImageView.kf.setImage(with: URL(string: photo), placeholder: UIImage.defaultProfileImageCircle)
        }

        postImageView.isHidden = item?.thumbnailPhoto == nil
        guard let date = TimeFormatHelper.soMuchTimeAgoNew(date: item?.createAt ?? 1000) else { return }


        var subtitleText = ""
			
			let action : ActionType = ActionType(rawValue: (item?.actionType)!)!
			let target : TargetType = TargetType(rawValue: (item?.targetType)!)!
			
			switch action {
			case .follow:
				subtitleText = item?.actionMessage ?? ""
				iconImageView.image = UIImage(named: String.get(.iconNotifPlus))
                userImageView.contentMode = .scaleAspectFill
                hidePostImage(value: false)
			case .comment, .commentSub:
				subtitleText = item?.actionMessage ?? ""
				iconImageView.image = UIImage(named: String.get(.iconNotifComment))
                userImageView.contentMode = .scaleAspectFill
                hidePostImage(value: false)
			case .like:
				switch target {
				case .feed:
					subtitleText = String.get(.likedYourPost)
                    hidePostImage(value: false)
                case .comment, .commentSub:
					subtitleText = String.get(.likedYourComment)
                    hidePostImage(value: false)
                case .donation_badge:
                    hidePostImage(value: true)
                    userImageView.image = UIImage(named: "iconDonationBadge")
                    userImageView.backgroundColor = .primary
                    userImageView.contentMode = .center
				default:
                    userImageView.contentMode = .scaleAspectFill
                    hidePostImage(value: false)
					break
				}
				iconImageView.image = UIImage(named: String.get(.iconNotifLike))
                userImageView.contentMode = .scaleAspectFill
                hidePostImage(value: false)
			case .mention:
				subtitleText = item?.actionMessage ?? ""
				iconImageView.image = UIImage(named: String.get(.iconNotifMention))
                userImageView.contentMode = .scaleAspectFill
                hidePostImage(value: false)
            case .unlock_badge, .update_badge:
                subtitleText = item?.actionMessage ?? ""
                hidePostImage(value: true)
                userImageView.image = UIImage(named: "iconDonationBadge")
                userImageView.backgroundColor = .primary
                userImageView.contentMode = .center
            case .feed:
                subtitleText = String.get(.likedYourPost)
                hidePostImage(value: false)
			}
			
        let attributedString = subtitleText.appendStringWithAtribute(string: "  \(date)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.placeholder])
        attributedString.setLineSpacing(spacing: 2)

        if item?.actionMessage?.count ?? 0 < 100 {
            subtitleLabel.attributedText = attributedString
        } else {
            let limitText = 100
            
            let stringWithLimitedText = String(subtitleText.prefix(limitText))
            let attributedStringWithDot = stringWithLimitedText.appendStringWithAtribute(string: "... \(date)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholder])
            attributedStringWithDot.setLineSpacing(spacing: 2)
            subtitleLabel.attributedText = attributedStringWithDot
        }
        
    }

    func hidePostImage(value: Bool) {
        iconImageView.isHidden = value
    }
}

