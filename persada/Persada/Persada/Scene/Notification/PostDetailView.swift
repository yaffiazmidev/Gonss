//
//  PostDetailView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class PostDetailView: UIView {
	
	// MARK: - Public Property
	
	var item: Feed!
	
	lazy var medias: [Medias] = []
	
	
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
	
	lazy var textView: AttrTextView = {
		let textView = AttrTextView()
		textView.backgroundColor = .white
		textView.textColor = .black
		textView.attrString = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.cgColor])
		return textView
	}()
	
	lazy var buttonSeeMore: PrimaryButton = {
		let button = PrimaryButton(type: .system)
		button.addTarget(self, action: #selector(handleSeeMore), for: .touchUpInside)
		button.setup(color: .clear, textColor: .contentGrey, font: .AirBnbCereal(.bold, size: 13))
		button.contentHorizontalAlignment = .leading
		button.setTitle("See more", for: .normal)
		return button
	}()
	
	let createAtLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = .AirBnbCereal(.book, size: 13)
		return label
	}()
	
	let usernameLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = .AirBnbCereal(.bold, size: 14)
		return label
	}()
	
	lazy var buttonLike : UIButton = {
		let button = UIButton(type: .system)
		button.addTarget(self, action: #selector(whenHandleTappedLikeButton), for: .touchUpInside)
		return button
	}()
	
	lazy var buttonComment : UIButton = {
		let button = UIButton(image: UIImage(named: "iconComment")!)
		button.addTarget(self, action: #selector(whenHandleTappedCommentButton), for: .touchUpInside)
		return button
	}()
	
	lazy var descriptionLabel: UILabel = {
		let label: UILabel = UILabel()
		label.numberOfLines = 2
		label.textColor = .black
		label.font = .AirBnbCereal(.book, size: 12)
		return label
	}()
	
	var totalLikeLabel = UILabel(text: "120", textColor: .black)
	var totalCommentLabel = UILabel(text: "130", textColor: .black)

	let cellPercentWidth: CGFloat = 0.7
	var scrollToEdgeEnabled = false
	
	lazy var mediaPostGridView : UIView = {
		let vw = UIView(frame: .zero)
		vw.backgroundColor = .clear
		return vw
	}()
	
	var selebCarouselView: NewSelebCarouselView = {
		let carousel = NewSelebCarouselView()
		carousel.view.layer.masksToBounds = false
		carousel.view.layer.cornerRadius = 16
		carousel.view.clipsToBounds = true
		return carousel
	}()
	
	// MARK: - Public Property
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)

		backgroundColor = .white
		let top = safeAreaLayoutGuide.topAnchor
		let left = safeAreaLayoutGuide.leftAnchor
		let right = safeAreaLayoutGuide.rightAnchor
		let bottom = safeAreaLayoutGuide.bottomAnchor
		let selebView = selebCarouselView.view!
		let buttons = UIStackView()
		[buttonLike, totalLikeLabel, buttonComment, totalCommentLabel, buttonShared, UIView(), buttonOption].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			buttons.addArrangedSubview($0)
		}
		buttons.alignment = .fill
		buttons.distribution = .fill
		buttons.axis = .horizontal
		buttons.spacing = 5
		
		[imageUser, usernameLabel, createAtLabel, selebCarouselView.view!, buttons, textView, buttonSeeMore].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		imageUser.anchor(top: top, left: left, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
		usernameLabel.anchor(top: top, left: imageUser.rightAnchor, bottom: nil, right: right, paddingTop: 12, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
		createAtLabel.anchor(top: usernameLabel.bottomAnchor, left: imageUser.rightAnchor, bottom: nil, right: right, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
		
		selebView.anchor(top: imageUser.bottomAnchor, left: left, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 300)
		
		buttons.anchor(top: selebView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
		
		buttonSeeMore.anchor(top: nil, left: left, bottom: bottom, right: right, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)

		textView.anchor(top: buttons.bottomAnchor, left: left, bottom: buttonSeeMore.topAnchor, right: right, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureItem(_ item: Feed?) {
		imageUser.loadImage(at: item?.account?.photo ?? "")
		usernameLabel.text = item?.account?.username
		
		textView.setText(text: item?.post?.postDescription ?? "", backgroundColor: .whiteSmoke, withHashtagColor: .contentGrey, andMentionColor: .secondary, andCallBack: handleTextView(_:_:), normalFont: .AirBnbCereal(.book, size: 13), hashTagFont: .AirBnbCereal(.bold, size: 13), mentionFont: .AirBnbCereal(.bold, size: 13))
		descriptionLabel.text = item?.post?.postDescription
		totalCommentLabel.text = "\(item?.comments ?? 0)"
		totalLikeLabel.text = "\(item?.likes ?? 0)"
		createAtLabel.text = "\(TimeFormatHelper.epochConverter(date: "", epoch: Double(item?.createAt ?? 0 * 1000), format: "dd MMMM yyyy"))"
		totalLikeLabel.text = "\(item?.likes ?? 0)"

		buttonLike.setImage(item?.isLike ?? false ? #imageLiteral(resourceName: "iconHeart") : #imageLiteral(resourceName: "iconLike"), for: .normal)
		self.item = item
		guard let heightText = item?.post?.postDescription?.height(withConstrainedWidth: frame.width, font: .AirBnbCereal(.book, size: 13)) else {
			return
		}
		buttonSeeMore.isHidden = (heightText < CGFloat(30) || heightText == 0) ? true : false
	}
	
	func handleTextView(_ text: String,_ type: wordType)  {
	}

	func configureMedias(_ value: [Medias]) {
		selebCarouselView.view.backgroundColor = .white
		selebCarouselView.items = value
		selebCarouselView.pageController.numberOfPages = value.count
	}
	
	@objc func handleSeeMore() {
	}
	
	@objc func whenHandleTappedFollowButton() {
	}
	
	@objc func handleWhenTappedImageProfile() {
	}
	
	func configureStatusLike(status: Bool) {
	}
	
	@objc func whenHandleTappedLikeButton() {
		
	}
	
	@objc func whenHandleTappedSharedButton() {
	 
	}
	
	@objc func whenHandleTappedReportButton() {
	}
	
	@objc func whenHandleTappedCommentButton() {
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
}

