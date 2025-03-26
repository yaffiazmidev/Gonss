//
//  StatusNewsDetailCell.swift
//  Persada
//
//  Created by Muhammad Noor on 07/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class StatusNewsDetailCell: UITableViewCell {
	
	// MARK: - Public Property
	
	var commentHandler: (() -> Void)?
	var sharedHandler: (() -> Void)?
	var followHandler: (() -> Void)?
	var likeHandler: (() -> Void)?
	
	lazy var buttonLike = UIButton(image: #imageLiteral(resourceName: "iconLike"))
	lazy var buttonComment = UIButton(image: #imageLiteral(resourceName: "iconComment"))
	lazy var buttonReport = UIButton(image: #imageLiteral(resourceName: "iconSharealt"))
	lazy var likesLabel = UILabel(text: "", font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .center)
	lazy var commentLabel = UILabel(text: "", font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .center)
	private let network = FeedNetworkModel()
	var viewModel: FeedItemCellViewModel?
	private var subscriptions = Set<AnyCancellable>()
	@Published var totalLike: Int = 0
	@Published var totalComment: Int = 0

	// MARK: - Public Method
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		[likesLabel, commentLabel].forEach {
			$0.backgroundColor = .white
		}

		let likeView = UIView()
		let commentView = UIView()

		[likeView, commentView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		[buttonLike, likesLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			likeView.addSubview($0)
		}

		[buttonComment, commentLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			commentView.addSubview($0)
		}

		buttonLike.anchor(top: likeView.topAnchor, left: likeView.leftAnchor, bottom: likeView.bottomAnchor)
		likesLabel.anchor(top: likeView.topAnchor, left: buttonLike.rightAnchor, bottom: likeView.bottomAnchor, right: likeView.rightAnchor, paddingLeft: 4, paddingRight: 20)

		buttonComment.anchor(top: commentView.topAnchor, left: commentView.leftAnchor, bottom: commentView.bottomAnchor)
		commentLabel.anchor(top: commentView.topAnchor, left: buttonComment.rightAnchor, bottom: commentView.bottomAnchor, right: commentView.rightAnchor, paddingLeft: 4, paddingRight: 20)
		
		let buttonStack = UIStackView(arrangedSubviews: [likeView, commentView, buttonReport, UIView()])
		buttonStack.spacing = 8
		buttonStack.axis = .horizontal
		buttonStack.distribution = .fill
		
		addSubview(buttonStack)
		buttonStack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 16)
		
		buttonLike.addTarget(self, action: #selector(whenHandleTappedLikeButton), for: .touchUpInside)
		buttonReport.addTarget(self, action: #selector(whenHandleTappedReportButton), for: .touchUpInside)
		buttonComment.addTarget(self, action: #selector(whenHandleTappedCommentButton), for: .touchUpInside)
		
		$totalLike.sink {
			print("item \($0)")
		}.store(in: &subscriptions)
	}
	
	func set(likes: String, comments: String, isLike: Bool) {
		likesLabel.text = likes
		commentLabel.text = comments
		if isLike == false {
			self.buttonLike.setImage(UIImage(named: String.get(.iconLike)), for: .normal)
		} else {
			self.buttonLike.setImage(UIImage(named: String.get(.iconHeart)), for: .normal)
		}
	}
	
	func bind(viewModel: FeedItemCellViewModel) {
		self.viewModel = viewModel
	}
	
	func like(id: String, status: String) {
		network.like(.likeFeed(id: id, status: status)).sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		}, receiveValue: { [weak self] (model: DefaultResponse) in
			guard let self = self else { return }
			
			if model.code == "1000" && status == "like" {
				self.totalLike += 1
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
		}, receiveValue: { [weak self] (model: DefaultResponse) in
			guard let self = self else { return }
			
			if model.code == "1000" && status == "unlike" {
				if self.totalLike > 0 {
					self.totalLike -= 1
				}
				self.likesLabel.text = "\(self.totalLike)"

				self.buttonLike.setImage(UIImage(named: String.get(.iconLike)), for: .normal)
			}
		}).store(in: &subscriptions)
	}
	
	@objc func whenHandleTappedLikeButton() {
		self.likeHandler?()
	}
	
	@objc func whenHandleTappedReportButton() {
		self.sharedHandler?()
	}
	
	@objc func whenHandleTappedCommentButton() {
		self.commentHandler?()
	}
	
	func updateLike(isLike : Bool, total : Int) {
		if isLike {
			self.likesLabel.text = "\(total)"
			self.buttonLike.setImage(UIImage(named: String.get(.iconHeart)), for: .normal)
		} else {
			self.likesLabel.text = "\(total)"
			self.buttonLike.setImage(UIImage(named: String.get(.iconLike)), for: .normal)
		}
	}
}
