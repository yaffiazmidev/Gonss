//
//  ChannelSearchContentView.swift
//  KipasKipas
//
//  Created by movan on 05/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ChannelSearchContentViewDelegate where Self: UIViewController {
	
}

final class ChannelSearchContentView: UIView {
	
	weak var delegate: ChannelSearchContentViewDelegate?
	
	static let cellId: String = "cellId"
	static let sectionCustomHeaderElementKind = "section-custom-header-element-kind"
	
	lazy var collectionView: UICollectionView = {
		let layout = createExploreSection()
		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		view.register(ChannelSearchContentItemCell.self, forCellWithReuseIdentifier: ChannelSearchContentView.cellId)
		view.register(
		ChannelSearchContentHeaderView.self,
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
		withReuseIdentifier: ChannelSearchContentHeaderView.reuseIdentifier)
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		addSubview(collectionView)
		collectionView.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension ChannelSearchContentView {
	
	private func createExploreSection() -> UICollectionViewCompositionalLayout {

        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupHeight = NSCollectionLayoutDimension.fractionalWidth(0.5)
        let groupSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(8)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize,
          elementKind:  UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: .flexible(16), trailing: nil, bottom: .flexible(16))

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.boundarySupplementaryItems = [sectionHeader]
        
		let layout = UICollectionViewCompositionalLayout(section: section)
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        layout.configuration = config

		return layout
	}
}
