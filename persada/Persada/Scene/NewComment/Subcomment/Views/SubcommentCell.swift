//
//  SubcommentCell.swift
//  Persada
//
//  Created by NOOR on 26/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class SubCommentCell: UICollectionViewCell {

	var item: Subcomment? {
		didSet {
			guard let comment = item else { return }

			usernameLabel.text = comment.account?.username ?? ""

//			let attributedText = NSMutableAttributedString(
//				string: comment.value ?? "",
//				attributes:[
//					NSAttributedString.Key.font : UIFont.Roboto(.regular, size: 12),
//					NSAttributedString.Key.foregroundColor : UIColor.black
//				]
//			)
//
//			attributedText.setLineSpacing(spacing: 3)
//			titleLabel.attributedText = attributedText
            titleLabel.text = comment.value ?? ""

			let dateAttributeText = NSMutableAttributedString(string:  Date(timeIntervalSince1970: TimeInterval((item?.createAt ?? 1000)/1000 )).timeAgoDisplay(), attributes: [NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 10)])

			dateLabel.attributedText = dateAttributeText
			totalLikeLabel.text = "\(comment.like ?? 0)"

			if !(comment.account?.photo?.isEmpty ?? false) {
				
				var url = "\(comment.account?.photo ?? "")"
				
				profileImageView.loadImage(at: url)
			}

			buttonLike.setImage(
				comment.isLike! ? UIImage(named: String.get(.iconHeart)) : UIImage(named: String.get(.iconLike)), for: .normal
			)
			buttonLike.setTitle("\n \(comment.like ?? 0)", for: .normal)
			
		}
	}

	var likeHandler: ((_ id: String, _ status: String) -> Void)?
	var deleteHandler: ((_ id: String) -> Void)?
	var reportHandler: ((_ id: String, _ accountId: String, _ imageUrl: String) -> Void)?
	var replyHandler: ((_ id: String) -> Void)?

//	let titleLabel: UITextView = {
//		let textView = UITextView()
//		textView.font = .Roboto(.regular, size: 14)
//		textView.backgroundColor = .white
//		textView.textColor = .grey
//		textView.isScrollEnabled = false
//		textView.isEditable = false
//		textView.textContainerInset = UIEdgeInsets.zero
//		textView.textContainer.lineFragmentPadding = 0
//		return textView
//	}()
    
    lazy var titleLabel: ActiveLabel = {
        let label: ActiveLabel = ActiveLabel()
        label.font = .Roboto(.regular, size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.mentionColor = .secondary
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textColor = .black
        label.enabledTypes = [.mention, .hashtag]
        
        return label
    }()


	let profileImageView: UIImageView = {
		let iv = UIImageView()
		iv.clipsToBounds = true
		iv.contentMode = .scaleAspectFill
		iv.layer.cornerRadius = 24 / 2
		iv.backgroundColor = .lightGray
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
		label.font = UIFont.Roboto(.medium, size: 10)
		return label
	}()

	let usernameLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = UIFont.Roboto(.medium, size: 12)
		return label
	}()

	lazy var totalLikeLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textAlignment = .center
		label.textColor = .placeholder
		label.font = UIFont.Roboto(.medium, size: 10)
		return label
	}()

	lazy var deleteButton: UIButton = {
		let button = UIButton(title: .get(.deletePost), titleColor: .primary)
		button.titleLabel?.font = UIFont.Roboto(.medium, size: 10)
		button.addTarget(self, action: #selector(self.handleDeleteButton), for: .touchUpInside)
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)

		contentView.translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .white
        
//        titleLabel.handleMentionTap { text in
//            print(text)
//        }
//
//        titleLabel.handleHashtagTap { text in
//            print(text)
//        }

		contentView.addSubViews([profileImageView, usernameLabel, titleLabel, buttonLike, dateLabel, totalLikeLabel, deleteButton])

		profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 24, height: 24)

		usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, right: buttonLike.leftAnchor, paddingLeft: 8, paddingRight: 16)

		buttonLike.anchor(top: usernameLabel.topAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 30, height: 30)

		titleLabel.anchor(top: usernameLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: nil, right: buttonLike.rightAnchor, paddingTop: 4 , paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)

		dateLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: contentView.bottomAnchor, right: nil, paddingTop: 4 , paddingLeft: 2, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)

		deleteButton.anchor(top: dateLabel.topAnchor, left: dateLabel.rightAnchor, bottom: dateLabel.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0)

		totalLikeLabel.anchor(top: buttonLike.bottomAnchor, left: buttonLike.leftAnchor, bottom: nil, right: buttonLike.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    
    func setupActiveLabel() {
        
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
	}

	@objc private func handleDeleteButton() {
		guard let subCommentId = item?.id else {return}
		self.deleteHandler?(subCommentId)
	}

	@objc private func handleReply() {
		self.replyHandler?(self.item?.id ?? "")
	}
}
