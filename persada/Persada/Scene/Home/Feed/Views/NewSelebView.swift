//
//  NewSelebView.swift
//  Persada
//
//  Created by Muhammad Noor on 17/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol NewSelebViewDelegate where Self: UIViewController {
	
	func refreshUI()
}

final class NewSelebView: UIView {
	
	weak var delegate: NewSelebViewDelegate?

	static let storyHeaderId = "storyHeaderId"
	static let shortcutId = "shortcutId"
	static let selebCellId = "selebCellId"
	
	var height: CGFloat = 420

	//MARK: - PRIVATE VARIAABLES
	lazy var collectionView: UICollectionView = {
		let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		view.register(StoryItemCell.self, forCellWithReuseIdentifier: NewSelebView.storyHeaderId)
		view.register(FeedItemCell.self, forCellWithReuseIdentifier: NewSelebView.selebCellId)
		return view
	}()
	
	func createLayout() -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
			switch section {
				case 0:
					return self.createStoryEventsSection()
				case 1:
					return self.createSelebSection()
				default:
					fatalError("Unexpected section in collection view")
			}
		}

		return layout
	}
	
	lazy var refreshController: UIRefreshControl = {
		let refresh = UIRefreshControl(backgroundColor: .white)
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
		return refresh
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)

		collectionView.refreshControl = refreshController
		addSubview(collectionView)
		collectionView.fillSuperviewSafeAreaLayoutGuide()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func handlePullToRefresh() {
		self.delegate?.refreshUI()
	}
}

extension NewSelebView {
	private func createStoryEventsSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5.5, bottom: 0, trailing: 5.5)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .absolute(120))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)

		return section
	}

	private func createSelebSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1), heightDimension: .estimated(height)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: .fixed(24), trailing: nil, bottom: .fixed(24))

		let groupSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1), heightDimension: .estimated(height)
		)
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)

		return section
	}

}

