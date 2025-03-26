//
//  NewsView.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 23/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

final class NewsView : UIView {
	
	let tableViewNews : UITableView = {
		let table = UITableView()
        table.register(UINib(nibName: "NewsBiggerTopTitleViewCell", bundle: nil), forCellReuseIdentifier: "NewsBiggerTopTitleViewCell")
        table.register(UINib(nibName: "NewsMultipleImageViewCell", bundle: nil), forCellReuseIdentifier: "NewsMultipleImageViewCell")
        table.register(UINib(nibName: "NewsTopTitleWithDescriptionViewCell", bundle: nil), forCellReuseIdentifier: "NewsTopTitleWithDescriptionViewCell")
        table.register(UINib(nibName: "NewsBottomTitleViewCell", bundle: nil), forCellReuseIdentifier: "NewsBottomTitleViewCell")
        table.register(UINib(nibName: "NewsListViewCell", bundle: nil), forCellReuseIdentifier: "NewsListViewCell")
		table.separatorStyle = .none
        table.estimatedRowHeight = 120
        table.rowHeight = UITableView.automaticDimension
		table.backgroundColor = .clear
		return table
	}()

	let headerCategory : NewsViewHeader = {
		let header = NewsViewHeader()
		return header
	}()
    
    let containerHeaderCategory: UIView = {
        let header = UIView()
        header.backgroundColor = .white
        return header
    }()
	
	lazy var imageSlider : UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 320)
		let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 320), collectionViewLayout: layout)
		collection.collectionViewLayout = layout
		collection.backgroundColor = .clear
		collection.isPagingEnabled = true
		collection.backgroundView = UIView.init(frame: CGRect.zero)
		collection.register(NewsImageCell.self, forCellWithReuseIdentifier: NewsCellIdentifier.imageNewsIdentifier.rawValue)
		collection.showsHorizontalScrollIndicator = false
		return collection
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		return refresh
	}()
    
    lazy var activityIndicator : UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.color = .primary
        return activityView
    }()
    
    var headerCategoryHeightConstraint: NSLayoutConstraint!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
        
        addSubview(tableViewNews)
        addSubview(containerHeaderCategory)
        containerHeaderCategory.addSubview(headerCategory)
        addSubview(activityIndicator)
        
        tableViewNews.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        tableViewNews.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, height: 120)
        containerHeaderCategory.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, height: 48)
        headerCategory.anchor(top: containerHeaderCategory.topAnchor, left: leftAnchor, bottom: containerHeaderCategory.bottomAnchor, right: rightAnchor, height: 48)
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator.anchor(width: 30, height: 30)
		
		bringSubviewToFront(activityIndicator)
	}
    
    func startLoading(){
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    func stopLoading(){
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}


enum NewsCellIdentifier : String {
	case newsCategoryIdentifier
	case imageNewsIdentifier
	case newsIdentifier
}
