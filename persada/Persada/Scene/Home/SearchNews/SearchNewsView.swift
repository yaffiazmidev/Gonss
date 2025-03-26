//
//  SearchNewsView.swift
//  KipasKipas
//
//  Created by movan on 16/12/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol SearchNewsViewDelegate where Self: UIViewController {
	
}

final class SearchNewsView: UIView {
	
	weak var delegate: SearchNewsViewDelegate?
	
	enum ViewTrait {
		static let leftMargin: CGFloat = 10.0
		static let padding: CGFloat = 16.0
		static let widht = UIScreen.main.bounds.width - 24
		static let placeHolderSearch: String = .get(.cariBerita)
	}
	
	lazy var searchBar: UITextField = {
		var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
		textfield.clipsToBounds = true
		textfield.placeholder = .get(.cariBerita)
		textfield.layer.borderWidth = 1
		textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
		textfield.layer.cornerRadius = 8
		textfield.textColor = .black
		textfield.textColor = .grey
		textfield.autocapitalizationType = .none
		
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
		imageView.image = UIImage(named: "")
		containerView.addSubview(imageView)
		imageView.center = containerView.center
		textfield.rightView = containerView
		
		return textfield
	}()
	
	lazy var collectionView: UICollectionView = {
		let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		view.registerCustomCell(NewsCell.self)
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		[searchBar, collectionView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingRight: ViewTrait.leftMargin, height: 40)
		
		collectionView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension SearchNewsView {
	
	func createLayout() -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
			
			let itemSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)
			)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
			
			let groupSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)
			)
			let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
			
			let section = NSCollectionLayoutSection(group: group)
			
			return section
		}

		return layout
	}
}
