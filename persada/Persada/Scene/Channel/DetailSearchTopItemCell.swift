//
//  DetailSearchTopItemCell.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class DetailSearchTopItemCell: UICollectionViewCell {
	
	// MARK: - Public Property
	
	var item: Feed! {
		didSet {
            imageView.loadImage(at: item.account?.photo ?? "", .w360)
			nameLabel.text = item.account?.username ?? ""
            imagePost.loadImage(at: item.post?.medias?.first?.url ?? "", .w360)
			postTextLabel.text = "\(item.post?.postDescription ?? "")"
			commentsLabel.text = ""
			likesLabel.text = ""
			dateLabel.text = ""
			likesLabel.text = ""
			
			buttonFollow.isHidden = item.isFollow ?? false
//			buttonLike.setImage(item.isLike! ? #imageLiteral(resourceName: "iconHeart") : #imageLiteral(resourceName: "iconLike"), for: .normal)
		}
	}
	
	var commentHandler: ((_ id: String) -> Void)?
	var reportHandler: ((_ id: String, _ accountId: String, _ imageUrl: String) -> Void)?
	var profileHandler: ((_ id: String, _ type: String) -> Void)?
	var followHandler: ((_ id: String) -> Void)?
	var likeHandler: ((_ id: String, _ status: String) -> Void)?
	var seeProductHandle: (() -> Void)?
	var visiStoreHandle: ((_ id: String) -> Void)?
	
	lazy var imageView: UIImageView = {
		let image = UIImageView(frame: .zero)
		image.translatesAutoresizingMaskIntoConstraints = false
		image.layer.cornerRadius = 20
		image.backgroundColor = .gray
		image.clipsToBounds = true
		image.contentMode = .scaleAspectFill
		image.isUserInteractionEnabled = true
		let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedImageProfile))
		image.addGestureRecognizer(imageTapGesture)
		return image
	}()
	
	lazy var imagePost : UIImageView = {
		let image = UIImageView(frame: .zero)
		image.translatesAutoresizingMaskIntoConstraints = false
		image.layer.cornerRadius = 20
		image.backgroundColor = .lightGray
		image.isUserInteractionEnabled = true
		image.clipsToBounds = true
		image.contentMode = .scaleAspectFill
		return image
	}()
	
	lazy var buttonFollow: BadgedButton = {
		let button = BadgedButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 20
		button.layer.masksToBounds = false
		button.setTitleColor(UIColor.init(hexString: "#BC1C22"), for: .normal)
		button.backgroundColor = UIColor.init(hexString: "#FAFAFA")
		button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
		button.titleLabel?.textColor = .red
		button.setImage(#imageLiteral(resourceName: "Union").withRenderingMode(.alwaysOriginal), for: .normal)
		button.addTarget(self, action: #selector(whenHandleTappedFollowButton), for: .touchUpInside)
		button.setTitle("Follow", for: .normal)
		return button
	}()
	
	lazy var buttonVisitStore: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 20
		button.backgroundColor = .clear
		button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
		button.setTitleColor(.gray, for: .normal)
		button.layer.masksToBounds = false
		button.addTarget(self, action: #selector(whenHandleTappedVisitStoreButton), for: .touchUpInside)
		button.setTitle("Visit Store", for: .normal)
		return button
	}()
	
	lazy var buttonSeeProduct: BadgedButton = {
		let button = BadgedButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 20
		button.backgroundColor = .clear
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
		button.layer.masksToBounds = false
		button.addTarget(self, action: #selector(whenHandleTappedSeeProductButton), for: .touchUpInside)
		button.setTitle("See Product", for: .normal)
		return button
	}()
	
	lazy var buttonReport : UIButton = {
		let button = UIButton(image: #imageLiteral(resourceName: "iconReport"))
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(whenHandleTappedReportButton), for: .touchUpInside)
		return button
	}()
	
	let dateLabel: UILabel = {
		let label: UILabel = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .black
		label.font = UIFont.systemFont(ofSize: 12)
		return label
	}()
	
	let nameLabel: UILabel = {
		let label: UILabel = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .black
		label.font = UIFont.boldSystemFont(ofSize: 14)
		return label
	}()
	
	lazy var buttonLike : UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(named: "iconLike"), for: .normal)
		button.addTarget(self, action: #selector(whenHandleTappedLikeButton), for: .touchUpInside)
		return button
	}()
	
	lazy var buttonComment : UIButton = {
		let button = UIButton(image: UIImage(named: "iconComment")!)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(whenHandleTappedCommentButton), for: .touchUpInside)
		return button
	}()
	
	let postTextLabel = UILabel(text: "Here is my post text")
	let likesLabel = UILabel(text: "120", textColor: .black)
	let commentsLabel = UILabel(text: "130", textColor: .black)
	
	let imageViewGrid : UIView = {
		let vw = UIView(frame: .zero)
		vw.translatesAutoresizingMaskIntoConstraints = false
		vw.isUserInteractionEnabled = true
		vw.backgroundColor = .clear
		return vw
	}()
	
	let viewProduct : UIView = {
		let vw = UIView(frame: .zero)
		vw.translatesAutoresizingMaskIntoConstraints = false
		vw.isUserInteractionEnabled = true
		vw.backgroundColor = .whiteSnow
		return vw
	}()
	
	// MARK: - Public Method
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .white
		
		imageViewGrid.addSubview(imagePost)
		imagePost.fillSuperviewSafeAreaLayoutGuide()
		
		imagePost.addSubview(viewProduct)
		viewProduct.anchor(top: nil, left: imagePost.leftAnchor, bottom: imagePost.bottomAnchor, right: imagePost.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 42)
		
		viewProduct.addSubview(buttonVisitStore)
		viewProduct.addSubview(buttonSeeProduct)
		
		buttonVisitStore.anchor(top: viewProduct.topAnchor, left: viewProduct.leftAnchor, bottom: viewProduct.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 90, height: 0)
		
		buttonSeeProduct.anchor(top: viewProduct.topAnchor, left: nil, bottom: viewProduct.bottomAnchor, right: viewProduct.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 0)
		
		stack(hstack(
			imageView.withHeight(40).withWidth(40), stack(nameLabel, dateLabel), buttonFollow.withHeight(40).withWidth(80),spacing: 8).padTop(12),
			  imageViewGrid,
			  hstack(buttonLike.withWidth(30).withHeight(30),likesLabel, buttonComment.withWidth(30).withHeight(30), commentsLabel, UIView(), buttonReport.withSize(CGSize(width: 30, height: 30))).padTop(4),
			  postTextLabel,
			  spacing: 8).withMargins(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func whenHandleTappedFollowButton() {
		self.followHandler?(self.item.account?.id ?? "")
		self.buttonFollow.isHidden = true
	}
	
	@objc func handleWhenTappedImageProfile() {
		self.profileHandler?(self.item.account?.id ?? "", self.item.typePost ?? "")
	}
	
	func configureStatusLike(status: Bool) {
		if status {
			self.buttonLike.imageView?.image = #imageLiteral(resourceName: "iconHeart")
		} else {
			self.buttonLike.imageView?.image = #imageLiteral(resourceName: "iconLike")
		}
	}
	
	@objc func whenHandleTappedLikeButton() {
		if self.item.isLike == true {
			self.likeHandler?(self.item.id ?? "", "unlike")
		} else {
			self.likeHandler?(self.item.id ?? "", "like")
		}
	}
	
	@objc func whenHandleTappedReportButton() {
		self.reportHandler?(self.item.post?.id ?? "", self.item.account?.id ?? "" ,self.item.post?.medias?.first?.url ?? "")
	}
	
	@objc func whenHandleTappedCommentButton() {
		self.commentHandler?(self.item.id ?? "")
	}
	
	@objc func whenHandleTappedVisitStoreButton() {
		self.visiStoreHandle?(self.item.id ?? "")
	}
	
	@objc func whenHandleTappedSeeProductButton() {
		self.seeProductHandle?()
	}
}


