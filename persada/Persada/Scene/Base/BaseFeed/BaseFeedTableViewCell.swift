//
//  BaseFeedTableViewCell.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 16/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class BaseFeedTableViewCell: UITableViewCell {

	var item: Feed? = nil

	lazy var medias: [Medias] = []

	var commentHandler: ((_ item: Feed) -> Void)?
	var reportHandler: ((_ id: String, _ accountId: String, _ imageUrl: String) -> Void)?
	var profileHandler: ((_ id: String, _ type: String) -> Void)?
	var followHandler: ((_ id: String) -> Void)?
	var sharedHandler: (() -> Void)?
	var seeMoreHandler: ((_ text: String) -> Void)?
	var mentionHandler: ((_ text: String,_ type: wordType) -> Void)?

	var updateFeed: ((_ feed: Feed) -> Void)?

	lazy var imageUser: UIImageView = {
		let image = UIImageView(frame: .zero)
		image.layer.cornerRadius = 20
		image.backgroundColor = .gray
		image.clipsToBounds = true
		image.contentMode = .scaleAspectFill
		image.isUserInteractionEnabled = true
		let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedImageProfile))
		image.addGestureRecognizer(imageTapGesture)
		return image
	}()

	lazy var buttonOption : UIButton = {
		let button = UIButton(image: #imageLiteral(resourceName: "iconReport"))
		button.addTarget(self, action: #selector(whenHandleTappedReportButton), for: .touchUpInside)
		return button
	}()

	lazy var buttonShared : UIButton = {
		let button = UIButton(image: UIImage(named: String.get(.iconSharealt))!)
		button.addTarget(self, action: #selector(whenHandleTappedSharedButton), for: .touchUpInside)
		return button
	}()

	lazy var textView: ActiveLabel = {
		let label: ActiveLabel = ActiveLabel()
		label.font = .Roboto(.regular, size: 12)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.mentionColor = .secondary
		label.numberOfLines = 3
		label.backgroundColor = .white
		label.textColor = .black
		return label
	}()

	lazy var buttonSeeMore: PrimaryButton = {
		let button = PrimaryButton(type: .system)
		button.addTarget(self, action: #selector(handleSeeMore), for: .touchUpInside)
		button.setup(color: .clear, textColor: .contentGrey, font: .Roboto(.bold, size: 13))
		button.contentHorizontalAlignment = .leading
		button.setTitle("See more", for: .normal)
		return button
	}()

	let createAtLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = .Roboto(.regular, size: 10)
		return label
	}()

	let usernameLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = .Roboto(.bold, size: 14)
		return label
	}()

	lazy var buttonLike : UIButton = {
		let button = UIButton(type: .system)
		button.addTarget(self, action: #selector(whenHandleTappedLikeButton), for: .touchUpInside)
		return button
	}()

	lazy var buttonComment : UIButton = {
		let button = UIButton(image: UIImage(named: String.get(.iconComment))!)
		button.addTarget(self, action: #selector(whenHandleTappedCommentButton), for: .touchUpInside)
		return button
	}()

	lazy var descriptionLabel: UILabel = {
		let label: UILabel = UILabel()
		label.numberOfLines = 2
		label.textColor = .black
		label.font = .Roboto(.regular, size: 12)
		return label
	}()

    var totalLikeLabel = UILabel(text: "120", font: .Roboto(.medium, size: 13), textColor: .black)
	var totalCommentLabel = UILabel(text: "130", font: .Roboto(.medium, size: 13), textColor: .black)

	let cellPercentWidth: CGFloat = 0.7
	var scrollToEdgeEnabled = false

	lazy var mediaPostGridView : UIView = {
		let vw = UIView(frame: .zero)
		vw.backgroundColor = .clear
		return vw
	}()

	let postTextLabel: UILabel = {
		let label: UILabel = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .Roboto(.regular, size: 13)
		label.numberOfLines = 0
		label.textColor = .black
		return label
	}()

	lazy var selebCarouselView: NewSelebCarouselView = {
		let carousel = NewSelebCarouselView()
		carousel.view.backgroundColor = .white
		return carousel
	}()

	lazy var fullImage: AGVideoPlayerView = {
		let image = AGVideoPlayerView(frame: .zero)
		image.translatesAutoresizingMaskIntoConstraints = false
		image.layer.masksToBounds = false
		image.layer.cornerRadius = 8
		image.clipsToBounds = true
		image.contentMode = .scaleAspectFill
		image.shouldAutoplay = false
		image.shouldAutoRepeat = true
		image.shouldSwitchToFullscreen = false
		image.showsCustomControls = true
		return image
	}()


	internal var aspectConstraint : NSLayoutConstraint? {
		didSet {
			if oldValue != nil {
				fullImage.removeConstraint(oldValue!)
			}
			if aspectConstraint != nil {
			 	fullImage.addConstraint(aspectConstraint!)
			}
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		aspectConstraint = nil
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
				contentView.addSubview(fullImage)

				buttonSeeMore.constrainHeight(30)
				[buttonLike, buttonComment, buttonShared, buttonOption].forEach {
					$0.widthAnchor.constraint(equalToConstant: 30).isActive = true
					$0.heightAnchor.constraint(equalToConstant: 30).isActive = true
				}

				let likeStack: UIStackView = hstack(buttonLike, totalLikeLabel, spacing: 4, alignment: .fill, distribution: .fillEqually)
				let commentStack: UIStackView = hstack( buttonComment, totalCommentLabel, spacing: 4, alignment: .fill, distribution: .fillEqually)
				let mainStack: UIStackView = stack(hstack(
																						imageUser.withHeight(40).withWidth(40), stack(usernameLabel, createAtLabel), UIView(),spacing: 8).padTop(12),
																					  selebCarouselView.view,
																					 hstack(likeStack, commentStack, buttonShared, UIView(), buttonOption, spacing: 0).padTop(4),
																					 textView,
																					 buttonSeeMore,
																					 spacing: 8).withMargins(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

				selebCarouselView.view.isHidden = true


				addSubview(mainStack)
				mainStack.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
				mainStack.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

	}

	required init?(coder: NSCoder) {
		fatalError("errorrr")
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
		if selected {
			let view =  UIView()
			view.backgroundColor = .primaryLowTint
			self.selectedBackgroundView = view
		} else {
			self.backgroundColor = .clear
		}
	}
}


extension BaseFeedTableViewCell {

	func setup(item: Feed){

		guard let medias = item.post?.medias else {return}
		configureMedias(medias)

		imageUser.loadImage(at:  item.account?.photo ?? "")
		usernameLabel.text = item.account?.username

		textView.text = item.post?.postDescription ?? ""
		textView.mentionTapHandler = { (text) in
			self.handleTextView(text)
		}
		descriptionLabel.text = item.post?.postDescription
		totalCommentLabel.text = "\(item.comments ?? 0)"
		totalLikeLabel.text = "\(item.likes ?? 0)"
		createAtLabel.text = "\(TimeFormatHelper.epochConverter(date: "", epoch: Double(item.createAt ?? 0 * 1000), format: "dd MMMM yyyy"))"
		totalLikeLabel.text = "\(item.likes ?? 0)"

		buttonLike.setImage(item.isLike ?? false ? UIImage(named: String.get(.iconHeart)) : UIImage(named: String.get(.iconLike)), 	for: .normal)
		self.item = item

		buttonSeeMore.isHidden =  item.post?.postDescription?.count ?? 0 <= 150

	}

	func setupImage(feed: Feed) {
		fullImage.isHidden = false
		selebCarouselView.view.isHidden = true

		guard let item = feed.post?.medias?.first else {return}

		let height:Float = 1920.0
		let width:Float = 1920.0

		setupViewRatio(width: width, height: height, view: fullImage)

		if item.type == "image" {
			fullImage.showsCustomControls = false
			fullImage.previewImageUrl = URL(string: item.thumbnail?.medium ?? "")
			fullImage.videoUrl = nil
		} else if (item.type == "video") {
			fullImage.showsCustomControls = true
			fullImage.videoUrl = URL(string: item.url ?? "")
			fullImage.shouldAutoplay = true
			fullImage.shouldAutoRepeat = true
			fullImage.minimumVisibilityValueForStartAutoPlay = 0.9
			fullImage.previewImageUrl = nil
		}
	}

	func setupViewRatio(width: Float, height: Float, view: UIView) {
		let ratio = width/height

		let constraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: CGFloat(ratio), constant: 0.0)
		constraint.priority = UILayoutPriority(rawValue: 999)


		aspectConstraint = constraint
	}

	func configureItem(_ item: Feed?) {
		imageUser.loadImage(at: item?.account?.photo ?? "")
		usernameLabel.text = item?.account?.username

		textView.text = item?.post?.postDescription ?? ""
		textView.mentionTapHandler = { (text) in
			self.handleTextView(text)
		}
		descriptionLabel.text = item?.post?.postDescription
		totalCommentLabel.text = "\(item?.comments ?? 0)"
		totalLikeLabel.text = "\(item?.likes ?? 0)"
		createAtLabel.text = "\(TimeFormatHelper.epochConverter(date: "", epoch: Double(item?.createAt ?? 0 * 1000), format: "dd MMMM yyyy"))"
		totalLikeLabel.text = "\(item?.likes ?? 0)"

		buttonLike.setImage(item?.isLike ?? false ? #imageLiteral(resourceName: "iconHeart") : #imageLiteral(resourceName: "iconLike"), for: .normal)
		self.item = item

		buttonSeeMore.isHidden =  item?.post?.postDescription?.count ?? 0 <= 150

	}

	func handleTextView(_ text: String)  {
		mentionHandler?(text, .mention)
	}

	func configureMedias(_ value: [Medias]) {

		guard let post = value.first else {return}
		let height:Float = 1920.0
		let width:Float = 1920.0

		setupViewRatio(width: width, height: height, view: fullImage)

		selebCarouselView.view.isHidden = false
		fullImage.isHidden = true
		selebCarouselView.view.backgroundColor = .white
//		selebCarouselView.items = value
//		selebCarouselView.setIsPageView(values: value.count)
//		selebCarouselView.pageController.numberOfPages = value.count
	}

	@objc func handleSeeMore() {
		guard let description = self.item?.post?.postDescription else {
			return
		}

		self.seeMoreHandler?(description)
	}

	@objc func whenHandleTappedFollowButton() {
		self.followHandler?(self.item?.account?.id ?? "")
	}

	@objc func handleWhenTappedImageProfile() {
		self.profileHandler?(self.item?.account?.id ?? "", self.item?.typePost ?? "")
	}

	func configureStatusLike(status: Bool) {
		if status {
			self.buttonLike.imageView?.image = UIImage(named: String.get(.iconHeart))
		} else {
			self.buttonLike.imageView?.image = UIImage(named: String.get(.iconLike))
		}
	}

	@objc func whenHandleTappedLikeButton() {
		let isLike = self.item?.isLike ?? false
		let likeCounter = self.item?.likes  ?? 0
		self.item?.isLike = !isLike
		self.item?.likes = likeCounter + (!isLike ? 1 : -1)
		self.updateFeed?(self.item!)
	}

	@objc func whenHandleTappedSharedButton() {
		self.sharedHandler?()
	}

	@objc func whenHandleTappedReportButton() {
		self.reportHandler?(self.item?.id ?? "", self.item?.account?.id ?? "" ,self.item?.post?.medias?.first?.thumbnail?.medium ?? "")
	}

	@objc func whenHandleTappedCommentButton() {
		guard let item = self.item else {
			return
		}

		self.commentHandler?(item)
	}
}

