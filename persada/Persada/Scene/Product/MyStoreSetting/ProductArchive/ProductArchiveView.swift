//
//  ProductArchiveView.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 22/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

protocol ProductArchiveViewDelegate where Self: UIViewController {
    func refreshUI()
}

class ProductArchiveView: UIView {
    
    private enum ViewTrait {
        static let iconSearch: String = String.get(.iconSearch)
        static let placeHolderSearch: String = String.get(.placeHolderSearchArchiveProduct)
    }
    
    var delegate: ProductArchiveViewDelegate?
    
    lazy var searchBar: UITextField = {
        var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        textfield.clipsToBounds = true
        textfield.placeholder = ViewTrait.placeHolderSearch
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
        textfield.layer.cornerRadius = 8
        textfield.textColor = .grey
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.placeholder,
            NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12) // Note the !
        ]
        textfield.backgroundColor = UIColor.white
        
        textfield.attributedPlaceholder = NSAttributedString(string: ViewTrait.placeHolderSearch, attributes: attributes)
        textfield.rightViewMode = .always
        
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        textfield.leftViewMode = .always
        
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: self.frame.height))
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        imageView.image = UIImage(named: ViewTrait.iconSearch)
        containerView.addSubview(imageView)
        imageView.center = containerView.center
        textfield.rightView = containerView
        
        
        return textfield
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerCustomCell(ProductItemCell.self)
        collectionView.backgroundColor = .white
        collectionView.refreshControl = refreshController
        return collectionView
    }()
    
    let image: UIImageView = UIImageView(image: UIImage(named: String.get(.iconNotFoundBold)))
    
    let label: UILabel = UILabel(font: .Roboto(.medium, size: 14), textColor: .contentGrey, textAlignment: .center, numberOfLines: 0)

    let notFoundLabel: UILabel = UILabel(font: .Roboto(.medium, size: 12), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)

    
    lazy var emptyStateView: UIView = {
        let view: UIView = UIView()
        
        view.addSubview(label)
        view.addSubview(image)
        view.addSubview(notFoundLabel)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:0).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant:0).isActive = true
        
        image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant:0).isActive = true
        image.anchor(bottom: label.topAnchor, paddingBottom: 12)
        
        notFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        notFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant:0).isActive = true
        notFoundLabel.anchor(top: label.bottomAnchor, paddingTop: 12)
        notFoundLabel.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 43.5, paddingRight: 43.5)
        
        return view
    }()
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            return self.productSection()
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
        backgroundColor = .white

        addSubview(searchBar)
        addSubview(collectionView)
        addSubview(emptyStateView)
        
        searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, height: 40)
        
        collectionView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 16)
        
        emptyStateView.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor)
        
        emptyStateView.isHidden = true
        searchBar.isHidden = true
        collectionView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handlePullToRefresh() {
        self.delegate?.refreshUI()
    }
    
}

extension ProductArchiveView {
    
    private func productSection() -> NSCollectionLayoutSection {
        let inset: CGFloat = 15
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: 4, bottom: 8, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalWidth(0.72))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)

        return section
    }
    
}


