//
//  AnotherUserProfileView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

final class AnotherUserProfileView: UIView {
	
	weak var delegate: NewUserProfileViewDelegate?
	
	enum ViewTrait {
		static let padding: CGFloat = 16.0
		static let cellId: String = "cellId"
		static let headerId: String = "headerId"
		static let sectionHeaderElementKind = "section-header-element-kind"
	}
		var bioLabelTopAnchorToUserImage: NSLayoutConstraint?
		var shopButtonTopAnchorToBioLabel: NSLayoutConstraint?
		var shopButtonTopAnchorToUserImage: NSLayoutConstraint?
	
	lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		let collectView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectView.register(NewUserProfileItemCell.self, forCellWithReuseIdentifier: ViewTrait.cellId)
		collectView.register(
		AnotherUserProfileHeaderView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: ViewTrait.headerId)
		collectView.translatesAutoresizingMaskIntoConstraints = false
		collectView.backgroundColor = .white
        collectView.refreshControl = refreshControl
		return collectView
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handlePullToRequest), for: .valueChanged)
		return refresh
	}()
	
    lazy var labelEmptyPlaceholder: UILabel = {
        let label = UILabel(text: String.get(.emptyUserProfilePost), font: UIFont.Roboto(.bold, size: 14), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        label.isHidden = true
        return label
    }()
    
    lazy var progress: UIActivityIndicatorView = {
        let progress = UIActivityIndicatorView()
        progress.color = .primary
        progress.startAnimating()
        return progress
    }()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(collectionView)
        collectionView.addSubview(labelEmptyPlaceholder)
        
        collectionView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
		
        collectionView.addSubview(progress)
        progress.centerInSuperview()
		labelEmptyPlaceholder.centerXTo(collectionView.centerXAnchor)
		labelEmptyPlaceholder.centerYTo(collectionView.centerYAnchor, 100)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func handlePullToRequest() {
		self.delegate?.refresh()
	}
}
