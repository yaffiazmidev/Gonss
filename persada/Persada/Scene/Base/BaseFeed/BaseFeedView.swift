//
//  BaseFeedView.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 16/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

// ******
// use this class to show feed
// inherit this class! don't repeat your self
// ******

import UIKit
import NVActivityIndicatorView

enum FeedCustomCell: Int {
	case story = 100000000000
	case multiple = 2000000000
}

protocol BaseFeedViewDelegate where Self: UIViewController {

	func refreshUI()
}

public class BaseFeedView: UIView {

	static let cellId = "feedCell"
	static let storyCellId = "storyCell"
	weak var delegate: BaseFeedViewDelegate?

	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .grouped)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = footerView
		table.refreshControl = refreshController
		table.rowHeight = UITableView.automaticDimension
        print("tinggi cell \(UIScreen.main.bounds.height - 200)")
        table.estimatedRowHeight = UIScreen.main.bounds.height - 200
		table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		table.separatorStyle = .none
		table.backgroundColor = .clear
		table.allowsSelection = false
		table.showsVerticalScrollIndicator = false
		table.register(UINib(nibName: BaseFeedTableViewCell2.self.className, bundle: nil), forCellReuseIdentifier: BaseFeedTableViewCell2.self.reuseIdentifier)
		table.register(UINib(nibName: BaseFeedMultipleTableViewCell.self.className, bundle: nil), forCellReuseIdentifier: BaseFeedMultipleTableViewCell.self.reuseIdentifier)
		return table
	}()

	let collectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .white
		collectionView.registerCustomCell(StoryItemCell.self)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.allowsMultipleSelection = true
		return collectionView
	}()

	lazy var footerView: UIView = {
		let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
		customView.backgroundColor = UIColor.clear
		let activityView = UIActivityIndicatorView(style: .large)
		activityView.color = .black
		activityView.tintColor = .black
		customView.addSubview(activityView)
		activityView.anchor(top: customView.topAnchor, leading: customView.leadingAnchor, bottom: nil, trailing: customView.trailingAnchor)
		activityView.startAnimating()
		return customView
	}()

	lazy var refreshController: UIRefreshControl = {
		let refresh = UIRefreshControl(backgroundColor: .white)
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
		return refresh
	}()
    
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .primary, padding: 0)


    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        addSubview(loading)
        tableView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        loading.centerInSuperview(size: CGSize(width: 40, height: 40))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	@objc private func handlePullToRefresh() {
		self.delegate?.refreshUI()
	}
}
