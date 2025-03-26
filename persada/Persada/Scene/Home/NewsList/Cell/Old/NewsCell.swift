//
//  NewsCell.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

final class NewsCell: UICollectionViewCell {
	
	// MARK: - Public Property
	
	var item: NewsCellViewModel! {
		didSet {
			imagePost.loadImage(at: item.imageNewsUrl ?? "")
			postTextLabel.text = item.title ?? ""
			nameLabel.text = item.source
			dateLabel.text = "\(TimeFormatHelper.epochConverter(date: "", epoch: Double(item.published ?? 0 * 1000), format: "dd MMMM yyyy"))"
			likesLabel.text = "\(item.likes ?? 0)"
			commentLabel.text = "\(item.comment ?? 0)"
			configureStatusLike(status: item.isLike ?? false)
		}
	}
	
	var isLike = false
	let imagePost : UIImageView = {
		let image = UIImageView(frame: .zero)
		let img = UIImage(named: String.get(.empty))
		image.image = img
		image.translatesAutoresizingMaskIntoConstraints = false
		image.layer.cornerRadius = 8
		image.backgroundColor = .lightGray
		image.clipsToBounds = true
		image.contentMode = .scaleAspectFill
		return image
	}()
	
	let postTextLabel: UILabel = {
		let lbl = UILabel(text: "", font: .Roboto(.medium, size: 16), textColor: .black, textAlignment: .left, numberOfLines: 3)
		lbl.clipsToBounds = true
		return lbl
	}()
	
	let dateLabel: UILabel = {
		let lbl = UILabel(text: "", font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 1)
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.clipsToBounds = true
		lbl.textColor = .lightGray
		return lbl
	}()
	
	
	var commentHandler: (() -> Void)?
	var reportHandler: ((_ id: String, _ accountId: String, _ imageUrl: String) -> Void)?
	var followHandler: ((_ id: String) -> Void)?
	var likeHandler: (() -> Void)?
	var shareHandler: (() -> Void)?
	
	lazy var buttonLike = UIButton(image: UIImage(named: .get(.iconLike))!)
	lazy var buttonComment = UIButton(image: UIImage(named: .get(.iconComment))!)
	lazy var buttonShare = UIButton(image: UIImage(named: .get(.iconSharealt))!)
	let likesLabel = UILabel(text: "0", font: .Roboto(.bold, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
	let commentLabel = UILabel(text: "0", font: .Roboto(.bold, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
	let nameLabel = UILabel(text: "Name Label")
	private let network = FeedNetworkModel()
	private var subscriptions = Set<AnyCancellable>()
	@Published var totalLike: Int = 0
	@Published var totalComment: Int = 0
	
	let imageViewGrid : UIView = {
		let vw = UIView(frame: .zero)
		vw.translatesAutoresizingMaskIntoConstraints = false
		vw.backgroundColor = .clear
		return vw
	}()
	
	// MARK: - Public Method
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		imageViewGrid.addSubview(imagePost)
		imagePost.fillSuperview()
		[buttonLike, buttonLike, buttonShare].forEach {
			$0.heightAnchor.constraint(equalToConstant: 30).isActive = true
			$0.widthAnchor.constraint(equalToConstant: 30).isActive = true
			$0.contentMode = .scaleToFill
		}
		
//		let likeStack = hstack(buttonLike, likesLabel, spacing: 4, alignment: .center, distribution: .fill)
//		let commentStack = hstack(buttonComment, commentLabel, spacing: 4, alignment: .center, distribution: .fill)
//
//		let buttonsView = UIView()
//
//		buttonsView.addSubview(likeStack)
//		buttonsView.addSubview(commentStack)
//		buttonsView.addSubview(buttonShare)
//
//		likeStack.anchor(top: buttonsView.topAnchor, left: buttonsView.leftAnchor, bottom: buttonsView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//		commentStack.anchor(top: buttonsView.topAnchor, left: likeStack.rightAnchor	, bottom: buttonsView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//			buttonShare.anchor(top: buttonsView.topAnchor, left: commentStack.rightAnchor	, bottom: buttonsView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
		[imageViewGrid, postTextLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview($0)
		}
//		contentView.addSubview(buttonsView)

		imageViewGrid.anchor(top: contentView.topAnchor, right: contentView.rightAnchor, paddingRight: 20, width: 80, height: 80)
		
		addSubview(dateLabel)
		dateLabel.anchor(top: postTextLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: imageViewGrid.leftAnchor, paddingTop: 6, paddingLeft: 20, paddingRight: 16)
//		buttonsView.anchor(top: dateLabel.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: imageViewGrid.leftAnchor, paddingTop: 6, paddingLeft: 16, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
		postTextLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: imageViewGrid.leftAnchor, paddingLeft: 20, paddingRight: 16)

//		buttonLike.addTarget(self, action: #selector(whenHandleTappedLikeButton), for: .touchUpInside)
//		buttonShare.addTarget(self, action: #selector(whenHandleTappedReportButton), for: .touchUpInside)
//		buttonComment.addTarget(self, action: #selector(whenHandleTappedCommentButton), for: .touchUpInside)
	}
	
	func like(id: String, status: String) {
		network.like(.likeFeed(id: id, status: status)).sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		}, receiveValue: { (model: DefaultResponse) in
			if model.code == "1000" && status == "like" {
				self.totalLike += 1
				self.likesLabel.text = "\(self.totalLike)"
				self.isLike = true
				self.buttonLike.setImage(UIImage(named: String.get(.iconHeart)), for: .normal)
			}
		}).store(in: &subscriptions)
	}
	
	func unlike(id: String, status: String) {
		network.like(.likeFeed(id: id, status: status)).sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		}, receiveValue: { (model: DefaultResponse) in
			if model.code == "1000" && status == "unlike" {
				if self.totalLike > 0 {
					self.totalLike -= 1
				}
				self.likesLabel.text = "\(self.totalLike)"

				self.isLike = false
				self.buttonLike.setImage(UIImage(named: String.get(.iconLike)), for: .normal)
			}
		}).store(in: &subscriptions)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setUpCell(item: NewsCellViewModel){
		imagePost.loadImage(at: item.imageNewsUrl ?? "")
		postTextLabel.text = item.title ?? ""
		nameLabel.text = item.source
        if let source = item.source {
					let time = TimeFormatHelper.soMuchTimeAgoMini(date: item.published ?? 0) ?? "1h"
					stringImage(label: dateLabel, source: source, time: time, totalComment: "\(item.comment ?? 0)")
//            dateLabel.text = "\(source) \(TimeFormatHelper.epochConverter(date: "", epoch: Double(item.published ?? 0 * 1000), format: "dd/MM/yyyy HH:mm"))  "
        }
		likesLabel.text = "\(item.likes ?? 0)"
		commentLabel.text = "\(item.comment ?? 0)"
		configureStatusLike(status: item.isLike ?? false)
		totalLike = item.likes ?? 0
		totalComment = item.comment ?? 0
		isLike = item.isLike ?? false
	}
	
	func stringImage(label : UILabel, source: String, time: String, totalComment: String){
		let imageAttachment = NSTextAttachment()
		imageAttachment.image = UIImage(named: .get(.iconCommentSmall))
		// Set bound to reposition
		let imageOffsetY: CGFloat = -2.0
		imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
		// Create string with attachment
		let attachmentString = NSAttributedString(attachment: imageAttachment)
		// Initialize mutable string
		let completeText = NSMutableAttributedString(string: "\(source)     ")
		// Add image to mutable string
		completeText.append(attachmentString)
		// Add your text to mutable string
		let textAfterIcon = NSAttributedString(string: "\(totalComment)    \(time)")
		completeText.append(textAfterIcon)
		label.attributedText = completeText
	}
	
	func configureStatusLike(status: Bool) {
		if status {
			self.buttonLike.setImage(UIImage(named: String.get(.iconHeart)), for: .normal)
		} else {
			self.buttonLike.setImage(UIImage(named: String.get(.iconLike)), for: .normal)
		}
	}
	
	@objc func whenHandleTappedLikeButton() {
		self.likeHandler?()
	}
	
	@objc func whenHandleTappedReportButton() {
		self.shareHandler?()
	}
	
	@objc func whenHandleTappedCommentButton() {
		self.commentHandler?()
	}
}
