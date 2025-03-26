//
//  ChooseChannelView.swift
//  Persada
//
//  Created by movan on 03/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ChooseChannelViewDelegate where Self: UIViewController {
	func dismiss(_ channel: Channel?)
	func refresh()
}

final class ChooseChannelView: UIView {
	
	weak var delegate: ChooseChannelViewDelegate?
	
	enum ViewTrait {
		static let padding: CGFloat = 16.0
		static let placeHolderSearch: String = "Cari Channel"
		static let cellId: String = "cellId"
	}
	
	lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 70)
		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.register(ChooseChannelCell.self, forCellWithReuseIdentifier: ViewTrait.cellId)
		view.backgroundColor = .white
		view.layer.masksToBounds = true
		view.layer.cornerRadius = 8
		return view
	}()
	
	lazy var searchBar: UITextField = {
		var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
		textfield.clipsToBounds = true
		textfield.placeholder = ViewTrait.placeHolderSearch
		textfield.layer.borderWidth = 1
		textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
		textfield.layer.cornerRadius = 8
		textfield.textColor = .grey
		textfield.translatesAutoresizingMaskIntoConstraints = false
		textfield.backgroundColor = .whiteSmoke
		textfield.layer.masksToBounds = false
		let attributes = [
			NSAttributedString.Key.foregroundColor: UIColor.placeholder,
			NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12)
		]
		textfield.backgroundColor = UIColor.white
		
		textfield.attributedPlaceholder = NSAttributedString(string: ViewTrait.placeHolderSearch, attributes: attributes)
		textfield.rightViewMode = .always
		
		textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
		textfield.leftViewMode = .always
		
		let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: self.frame.height))
		let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
		imageView.image = UIImage(named: String.get(.iconSearch))
		containerView.addSubview(imageView)
		imageView.center = containerView.center
		textfield.rightView = containerView
		
		return textfield
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
		return refresh
	}()
	
	@objc private func handleRefresh() {
		self.delegate?.refresh()
	}
    
    lazy var emptyView: UIView = {
        let label = UILabel()
        label.text = "Channel tidak ditemukan, coba kata lain"
        label.font = .Roboto()
        label.font = UIFont(name: "AirbnbCerealApp-Book", size: 14)
        label.textColor = .grey
        
        let view = UIView()
        view.addSubview(label)
        label.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 18, paddingLeft: 2, paddingBottom: 26, paddingRight: 2)
        view.backgroundColor = .clear
        return view
    }()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		collectionView.refreshControl = refreshControl
		
		addSubview(searchBar)
		addSubview(collectionView)
        collectionView.addSubview(emptyView)

        searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingRight: ViewTrait.padding, height: 40)

		collectionView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding)
        
        emptyView.centerYTo(collectionView.centerYAnchor)
        emptyView.centerXTo(collectionView.centerXAnchor)
        emptyView.fillSuperview()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func createLayout() -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
			
			let itemSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)
			)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
			
			let groupSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)
			)
			let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
			
			let section = NSCollectionLayoutSection(group: group)
			
			return section
		}

		return layout
	}
}
