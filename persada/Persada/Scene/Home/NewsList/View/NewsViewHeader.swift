//
//  NewsViewHeader.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 23/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

final class NewsViewHeader : UIView {
	
	lazy var categoryCollectionView : UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 24, height: 24), collectionViewLayout: layout)
		collection.collectionViewLayout = layout
		collection.backgroundColor = .clear
		collection.backgroundView = UIView.init(frame: CGRect.zero)
		collection.register(NewsCategoryCell.self, forCellWithReuseIdentifier: NewsCellIdentifier.newsCategoryIdentifier.rawValue)
		collection.showsHorizontalScrollIndicator = false
		return collection
	}()
	
	
	lazy var searchButton : UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: String.get(.magnifyingglass)), for: .normal)
		button.tintColor = UIColor.grey
		return button
	}()
	
	lazy var dropDownButton : UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: String.get(.chevronDown)), for: .normal)
		button.tintColor = UIColor.grey
		return button
	}()
	
	lazy var line : UIView = {
		let view = UIView()
		
		view.backgroundColor = UIColor.white
		view.layer.shadowColor = UIColor.grey.cgColor
		view.layer.shadowOpacity = 0.4
		view.layer.shadowOffset = CGSize(width: 0, height: 3)
		view.layer.shadowRadius = 0.5
		return view
	}()
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		
		[categoryCollectionView, searchButton, dropDownButton, line].forEach {
			addSubview($0)
		}
		
		categoryCollectionView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 16, paddingBottom: 12, height: 24)
		searchButton.anchor(top: topAnchor, left: categoryCollectionView.rightAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 16, paddingBottom: 12, width: 24, height: 24)
		dropDownButton.anchor(top: topAnchor, left: searchButton.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 16, paddingBottom: 12, paddingRight: 16, width: 24, height: 24)
		
		line.anchor(top: categoryCollectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, height: 1)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	

}
