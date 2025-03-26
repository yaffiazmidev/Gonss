//
//  CommentCell.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class CommentCell: UICollectionViewCell {
	
	var item: Comment? {
		didSet {
			guard let comment = item else { return }

			usernameLabel.text = comment.account?.username ?? ""

			let attributedText = NSMutableAttributedString(
				string: comment.value ?? "",
				attributes:[
					NSAttributedString.Key.font : UIFont.Roboto(.regular, size: 12),
					NSAttributedString.Key.foregroundColor : UIColor.black
				]
			)
			
			attributedText.setLineSpacing(spacing: 3)
			titleLabel.attributedText = attributedText
			
			let dateAttributeText = NSMutableAttributedString(string:  Date(timeIntervalSince1970: TimeInterval((item?.createAt ?? 1000)/1000 )).timeAgoDisplay(), attributes: [NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 10)])
			
			dateLabel.attributedText = dateAttributeText
			totalLikeLabel.text = "\(comment.like ?? 0)"
			
			var photo = "\(comment.account?.photo ?? "")"
			
			if !(comment.account?.photo?.isEmpty ?? false) {
				profileImageView.loadImage(at: photo)
			}
			
			buttonLike.setImage(
				comment.isLike! ? UIImage(named: String.get(.iconHeart)) : UIImage(named: String.get(.iconLike)), for: .normal
				)
			buttonLike.setTitle("\n \(comment.like ?? 0)", for: .normal)
			buttonReply.setTitle("\((comment.commentSubs?.count ?? 0) + (comment.comments ?? 0)) Reply", for: .normal)
			
			if comment.account?.id == getIdUser() {
				buttonReport.isHidden = true
			} else {
				buttonDelete.isHidden = true
			}
		}
	}
	
	var likeHandler: ((_ id: String, _ status: String) -> Void)?
	var reportHandler: ((_ id: String, _ accountId: String, _ imageUrl: String) -> Void)?
	var replyHandler: ((_ id: String) -> Void)?
	var profileHandle: ((_ id: String, _ type: String) -> Void)?
	
	let titleLabel: UITextView = {
		let textView = UITextView()
		textView.font = .Roboto(.regular, size: 12)
		textView.backgroundColor = .white
		textView.textColor = .grey
		textView.isScrollEnabled = false
		textView.isEditable = false
		textView.textContainerInset = UIEdgeInsets.zero
		textView.textContainer.lineFragmentPadding = 0
		return textView
	}()
	
	let profileImageView: UIImageView = {
		let iv = UIImageView()
		iv.clipsToBounds = true
		iv.contentMode = .scaleAspectFill
		iv.layer.cornerRadius = 24 / 2
		iv.backgroundColor = .lightGray
		iv.isUserInteractionEnabled = true
		return iv
	}()
	
	lazy var buttonReport : UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Report", for: .normal)
		button.titleLabel?.textAlignment = .left
		button.titleLabel?.font = UIFont.Roboto(.medium, size: 10)
		button.setTitleColor(.placeholder, for: .normal)
		button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
		return button
	}()
	
	lazy var buttonReply : UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Reply", for: .normal)
		button.titleLabel?.font = UIFont.Roboto(.medium, size: 10)
		button.setTitleColor(.placeholder, for: .normal)
		button.addTarget(self, action: #selector(handleReply), for: .touchUpInside)
		return button
	}()
	
	lazy var buttonDelete : UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(.get(.deletePost), for: .normal)
		button.titleLabel?.font = UIFont.Roboto(.medium, size: 10)
		button.setTitleColor(.orangeColor, for: .normal)
		button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
		return button
	}()
	
	lazy var buttonStackView : UIStackView = {
		let stack = UIStackView()
		stack.hstack(buttonReport.withWidth(50), buttonDelete.withWidth(50))
		return stack
	}()
	
	lazy var buttonLike : UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(named: String.get(.iconLike)), for: .normal)
		button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
		return button
	}()
	
	let dateLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textAlignment = .left
		label.textColor = .placeholder
		label.font = UIFont.Roboto(.medium, size: 12)
		return label
	}()
	
	let usernameLabel: UILabel = UILabel(font: .Roboto(.bold, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 1)
	
	lazy var totalLikeLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textAlignment = .center
		label.textColor = .placeholder
		label.font = UIFont.Roboto(.medium, size: 12)
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		contentView.translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .white

		contentView.addSubViews([profileImageView, usernameLabel, titleLabel, buttonLike, dateLabel, buttonReply, buttonStackView, totalLikeLabel])
		
		profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 24, height: 24)

		usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor, right: buttonLike.leftAnchor, paddingLeft: 8, paddingBottom: 0, paddingRight: 16)

		buttonLike.anchor(top: usernameLabel.topAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 30, height: 30)

		titleLabel.anchor(top: usernameLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: nil, right: buttonLike.rightAnchor, paddingTop: 4 , paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)

		dateLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: contentView.bottomAnchor, right: nil, paddingTop: 4 , paddingLeft: 2, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)

		buttonReply.anchor(top: titleLabel.bottomAnchor, left: dateLabel.rightAnchor, bottom: contentView.bottomAnchor, right: nil, paddingTop: 4 , paddingLeft: 20, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
		
		buttonStackView.anchor(top: titleLabel.bottomAnchor, left: buttonReply.rightAnchor, bottom: contentView.bottomAnchor, right: nil, paddingTop: 4 , paddingLeft: 10, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)

		totalLikeLabel.anchor(top: buttonLike.bottomAnchor, left: buttonLike.leftAnchor, bottom: nil, right: buttonLike.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
		
		usernameLabel.onTap {
			self.showProfile()
		}
		
		profileImageView.onTap {
			self.showProfile()
		}
	}
	
	override func prepareForReuse() {
		buttonReport.isHidden = false
		buttonDelete.isHidden = false
	}
	
	private func showProfile() {
		let validId = self.item?.account?.id ?? ""
		let validType = self.item?.account?.accountType ?? ""
		self.profileHandle?(validId, validType)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func handleWhenTappedImageProfile() {
		var type = "social"
		if getRole() == "ROLE_SELEB" {
			type = "seleb"
		}
		self.profileHandle?(self.item?.account?.id ?? "", type)
	}

	lazy var width: NSLayoutConstraint = {
		let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
		width.isActive = true
		return width
	}()

	override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
		width.constant = bounds.size.width
		return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
	}

	func configureStatusLike(status: Bool) {
		if status {
			self.buttonLike.imageView?.image = UIImage(named: String.get(.iconHeart))
		} else {
			self.buttonLike.imageView?.image = UIImage(named: String.get(.iconLike))
		}
	}
	
	@objc private func handleReport() {
		self.reportHandler?(self.item?.id ?? "", self.item?.account?.id ?? "" ,"")
	}
	
	@objc private func handleLike() {
		if self.item?.isLike == true {
			self.likeHandler?(self.item?.id ?? "", "unlike")
		} else {
			self.likeHandler?(self.item?.id ?? "", "like")
		}
        let isLike = self.item?.isLike ?? false
        let likeCounter = self.item?.like  ?? 0
        self.item?.isLike = !isLike
        self.item?.like = likeCounter + (!isLike ? 1 : -1)

        if let comment = self.item {
           setupLike(item: comment)
        }
	}
	
	@objc private func handleReply() {
		self.replyHandler?(self.item?.id ?? "")
	}
    
    func setupLike(item: Comment){

        totalLikeLabel.text = "\(item.like ?? 0)"

        let statusImage = item.isLike ?? false ? UIImage(named: .get(.iconHeart))?.withRenderingMode(.alwaysOriginal) : UIImage(named: .get(.iconLike))?.withRenderingMode(.alwaysOriginal)
        buttonLike.setImage(statusImage, for: .normal)
        self.item = item
    }
}
