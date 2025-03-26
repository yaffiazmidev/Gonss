//
//  ChannelDetailView.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 31/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import UIKit

protocol ChannelDetailViewDelegate where Self: UIViewController {
	func refreshUI()
}

final class ChannelDetailView: UIView {

	weak var delegate: ChannelDetailViewDelegate?

	static let shortcutId = "shortcutId"
	static let selebCellId = "selebCellId"

	var collectionView: UICollectionView!
	var pinterestLayout: PinterestLayout!

	lazy var refreshController: UIRefreshControl = {
		let refresh = UIRefreshControl(backgroundColor: .white)
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
		return refresh
	}()

	lazy var loadingView: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .large)
		view.color = .systemBlue
		return view
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)

		pinterestLayout = PinterestLayout(numberOfColumns: 1)
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: pinterestLayout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .clear
//		collectionView.register(FeedItemCell.self, forCellWithReuseIdentifier: ChannelDetailView.selebCellId)

		collectionView.refreshControl = refreshController
		addSubview(collectionView)
		addSubview(loadingView)
		loadingView.startAnimating()

		loadingView.anchor(top: nil, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 32, height: 32)

		collectionView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: loadingView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
	}		

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc private func handlePullToRefresh() {
		self.delegate?.refreshUI()
	}

	func configureLike(index: Int, status: Bool) {
		//		itemsFeedCell[index]?.isLike = status
	}

	func configureFollow(index: Int) {
		//		itemsFeedCell[index]?.isFollow = true
	}

	func setupRefresh() {
		collectionView.refreshControl = refreshController
	}
}
