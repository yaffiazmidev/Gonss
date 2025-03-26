//
//  CommentHeaderView.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import AVKit

class CommentHeaderView: UICollectionReusableView {

	var comment: CommentHeaderCellViewModel? {
		didSet {
			guard let comment = comment else {
				return
			}
		}
	}
	var item: Feed? = nil
	var isCreated: Bool = false
	lazy var medias: [Medias] = []

	var reportHandler: ((_ id: String, _ accountId: String, _ imageUrl: String) -> Void)?
	var profileHandler: ((_ id: String, _ type: String) -> Void)?
	var updateFeed: ((_ feed: Feed) -> Void)?
	var likeHandler: ((_ feed: Feed) -> Void)?
	var sharedHandler: (() -> Void)?
	var mentionHandler: ((_ text: String) -> Void)?
	var hashtagHandler: ((_ text: String) -> Void)?


	lazy var imageUser: UIImageView = {
		let image = UIImageView(frame: .zero)
		image.layer.cornerRadius = 20
		image.backgroundColor = .gray
		image.clipsToBounds = true
		image.contentMode = .scaleAspectFill
		image.isUserInteractionEnabled = true
		return image
	}()
    
    lazy var emptyCommentLabel: UILabel = {
            let label = UILabel()
            label.text = "Tambahkan Komentar"
            label.textColor = .placeholder
            label.textAlignment = .center
            label.font = .Roboto(.medium, size: 12)
            return label
        }()

	lazy var buttonOption : UIButton = {
		let button = UIButton()
		let image = UIImage(named: String.get(.iconReport))
		button.setImage(image, for: .normal)
		return button
	}()
    
    lazy var buttonShared : UIButton =  {
       let button = UIButton(image: UIImage(named: String.get(.iconSharealt))!, target: self, action: #selector(whenHandleTappedSharedButton))
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
		
	lazy var textView: ActiveLabel = {
		let label: ActiveLabel = ActiveLabel(font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.mentionColor = .secondary
		label.autoresizesSubviews = true
		label.clearsContextBeforeDrawing = true
		label.isUserInteractionEnabled = true
		label.isEnabled = true
		label.translatesAutoresizingMaskIntoConstraints = false
//        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
		return label
	}()
    
    lazy var emptyTextView: ActiveLabel = {
        let label: ActiveLabel = ActiveLabel(font: .Roboto(.regular, size: 12), textColor: .white, textAlignment: .center, numberOfLines: 1)
//        label.mentionColor = .secondary
//        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = false
//        label.sizeToFit()
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        label.backgroundColor = .red
        label.text = String.get(.emptyComment)
        return label
    }()

	let createAtLabel: UILabel = UILabel(font: .Roboto(.regular, size: 10), textColor: .black, textAlignment: .left, numberOfLines: 1)
    let usernameLabel: UILabel = {
        let label = UILabel(font: .Roboto(.bold, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.isUserInteractionEnabled = true
        return label
    }()

	lazy var buttonLike : UIButton = {
		let button = UIButton(type: .system)
		button.addTarget(self, action: #selector(whenHandleTappedLikeButton), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
		return button
	}()

    lazy var buttonComment : UIButton = {
        let button = UIButton(image: UIImage(named: String.get(.iconComment))!)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
	lazy var descriptionLabel: UILabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 2)

	var totalLikeLabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
	var totalCommentLabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)

	let cellPercentWidth: CGFloat = 0.7
	var scrollToEdgeEnabled = false

	lazy var mediaPostGridView : UIView = {
		let vw = UIView(frame: .zero)
		vw.backgroundColor = .clear
		return vw
	}()

	let postTextLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 13), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	lazy var selebCarouselView: NewSelebCarouselView = {
		let carousel = NewSelebCarouselView()
		carousel.view.layer.masksToBounds = false
		carousel.view.layer.cornerRadius = 8
		carousel.view.backgroundColor = .white
		carousel.view.clipsToBounds = true
		return carousel
	}()

	lazy var fullImage: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = 8
		imageView.layer.masksToBounds = true
		imageView.clipsToBounds = true
		return imageView
	}()

    lazy var lineSeparatorView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        view.backgroundColor = .whiteSnow
        return view
    }()

	internal var aspectConstraint : NSLayoutConstraint? {
		didSet {
//			if oldValue != nil {
//				fullImage.removeConstraint(oldValue!)
//			}
//			if aspectConstraint != nil {
//				fullImage.addConstraint(aspectConstraint!)
//			}
		}
	}
	
	// MARK: - Public Method
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		addSubview(fullImage)
		translatesAutoresizingMaskIntoConstraints = false
		let spaceView = UIView()
        let commentUIView = UIView()
        commentUIView.backgroundColor = .red
        commentUIView.translatesAutoresizingMaskIntoConstraints = false
        commentUIView.addSubview(textView)
        let height = commentUIView.heightAnchor.constraint(equalToConstant: 30)
        height.priority = UILayoutPriority(rawValue: 750)
        height.isActive = true
        
        spaceView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
		[buttonLike, buttonComment, buttonShared, buttonOption].forEach {
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 30).isActive = true
		}


        let likeStack: UIStackView = hstack(buttonLike, totalLikeLabel, spacing: 4, alignment: .fill, distribution: .fillEqually)
        let commentStack: UIStackView = hstack( buttonComment, totalCommentLabel, spacing: 4, alignment: .fill, distribution: .fillEqually)
        
        let userNameStack: UIStackView = stack(usernameLabel.withHeight(20), createAtLabel.withHeight(12))
        userNameStack.isUserInteractionEnabled = true
        
        commentStack.heightAnchor.constraint(equalToConstant: 32).isActive = true
        likeStack.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let mainStack = stack(
            stack(
                hstack(
                    imageUser.withHeight(40).withWidth(40),
                    userNameStack,
                    UIView() ,buttonOption,spacing: 8).padTop(12),
                fullImage, selebCarouselView.view,
                hstack(likeStack, commentStack, buttonShared, UIView(), spacing: 0).padTop(4),
                textView, spacing: 8
            ).withMargins(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)),
            lineSeparatorView,
            emptyCommentLabel,
            spaceView,
            spacing: 8
        )

		selebCarouselView.view.isHidden = true
		addSubview(mainStack)
		
		let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedImageProfile))
		imageUser.addGestureRecognizer(imageTapGesture)
        
		let reportTapGesture = UITapGestureRecognizer(target: self, action: #selector(whenHandleTappedReportButton))
		buttonOption.addGestureRecognizer(reportTapGesture)
	}

	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
}

extension CommentHeaderView {
    
    func showEmptyCommentLabel(){
        self.emptyTextView.isHidden = true
        self.emptyCommentLabel.isHidden = false
    }

    func hideEmptyCommentLabel(){
        self.emptyTextView.isHidden = false
        self.emptyCommentLabel.isHidden = true
    }
	
	func setup(item: Feed){

		if item.post?.medias?.count ?? 0 > 1 {
			guard let medias = item.post?.medias else {return}
			configureMedias(medias)
		}
		else {
			setupImage(feed: item)
		}
		
		var photo = "\(item.account?.photo ?? "")"
        
		imageUser.loadImage(at: photo)
		usernameLabel.text = item.account?.username
        usernameLabel.onTap {
            self.profileHandler?(self.item?.account?.id ?? "", self.item?.typePost ?? "")
        }

//		textView.text = item.post?.postDescription ?? ""
//		textView.mentionTapHandler = { (text) in
//			self.handleTextView(text)
//		}
		
		let accountName = item.account?.username ?? ""
		let desc = item.post?.postDescription ?? ""
		textView.setLabel(prefixText: accountName, expanded: true, mainText: desc, 1000) {
			print("prefixTap")
			self.profileHandler?(self.item?.account?.id ?? "", self.item?.typePost ?? "")
		} suffixTap: {
			print("suffixTap")
		} mentionTap: { (text) in
			self.mentionHandler?(text)
			print("mentionTap")
		} hashtagTap: { (text) in
			print("hashtagTap")
			self.hashtagHandler?(text)
		}

//		descriptionLabel.text = item.post?.postDescription
		totalCommentLabel.text = "\(item.comments ?? 0)"
		totalLikeLabel.text = "\(item.likes ?? 0)"
		createAtLabel.text = Date(timeIntervalSince1970: TimeInterval((item.createAt ?? 1000)/1000 )).timeAgoDisplay()
		totalLikeLabel.text = "\(item.likes ?? 0)"

		let statusImage = item.isLike ?? false ? UIImage(named: .get(.iconHeart))?.withRenderingMode(.alwaysOriginal) : UIImage(named: .get(.iconLike))?.withRenderingMode(.alwaysOriginal)
		buttonLike.setImage(statusImage, for: .normal)
		self.item = item
	}
	
	func setupImage(feed: Feed) {
		fullImage.isHidden = false
		selebCarouselView.view.isHidden = true

		guard let post = feed.post?.medias?.first else {return}
		if post.type == "video" {
			configureMedias((feed.post?.medias!)!)
			return
		}
		let height = Float(post.metadata?.height ?? "400") ?? 400.0
		let width = Float(post.metadata?.width ?? "400") ?? 400.0

		setupViewRatio(width: width, height: height, view: fullImage)

		fullImage.loadImage(at: post.url ?? "")
	}

	func setupViewRatio(width: Float, height: Float, view: UIView) {
		let ratio = width/height

        let constraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: CGFloat(ratio), constant: 0.0)
        constraint.isActive = true
//		constraint.priority = UILayoutPriority(rawValue: 1000)
        view.constraints.forEach { view.removeConstraint($0) }
        view.addConstraint(constraint)

//		aspectConstraint = constraint
	}
	
//	func handleTextView(_ text: String)  {
//		mentionHandler?(text, .mention)
//	}

	func configureMedias(_ value: [Medias]) {

		guard let post = value.first else {return}
		let height = Float(post.metadata?.height ?? "1920") ?? 1920.0
		let width = Float(post.metadata?.width ?? "1920") ?? 1920.0

		setupViewRatio(width: width, height: height, view: fullImage)

		selebCarouselView.view.isHidden = false
		fullImage.isHidden = true
		selebCarouselView.view.backgroundColor = .white
		if isCreated == false {
			selebCarouselView.items = value
			print("Value anda \(value)")
		}
		selebCarouselView.setIsPageView(values: value.count)
		selebCarouselView.pageController.numberOfPages = value.count
	}

	@objc func handleWhenTappedImageProfile() {
		self.profileHandler?(self.item?.account?.id ?? "", self.item?.typePost ?? "")
	}

	func configureStatusLike(status: Bool) {
		if status {
			self.buttonLike.imageView?.image = UIImage(named: .get(.iconHeart))?.withRenderingMode(.alwaysOriginal)
		} else {
			self.buttonLike.imageView?.image = UIImage(named: .get(.iconLike))?.withRenderingMode(.alwaysOriginal)
		}
	}

	@objc func whenHandleTappedLikeButton() {
		let isLike = self.item?.isLike ?? false
		let likeCounter = self.item?.likes  ?? 0
		self.item?.isLike = !isLike
		self.item?.likes = likeCounter + (!isLike ? 1 : -1)
		if let feed = self.item {
			self.likeHandler?(feed)
			setup(item: feed)
		}
	}

	@objc func whenHandleTappedSharedButton() {
		self.sharedHandler?()
	}

	@objc func whenHandleTappedReportButton() {
		self.reportHandler?(self.item?.id ?? "", self.item?.account?.id ?? "" ,self.item?.post?.medias?.first?.thumbnail?.medium ?? "")
	}


}

struct CommentHeaderCellViewModel {
	let description: String?
	let date: Int?
	let username: String?
	let imageUrl: String?
	let feed: Feed?
	
	init(description: String, username: String, imageUrl: String, date: Int, feed: Feed?) {
		self.description = description
		self.username = username
		self.imageUrl = imageUrl
		self.date = date
		self.feed = feed
	}
}
