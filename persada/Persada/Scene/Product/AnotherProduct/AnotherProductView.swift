//
//  AnotherProductView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/06/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol AnotherProductViewDelegate where Self: UIViewController {
    func addAddress()
    func refreshUI()
}

final class AnotherProductView: UIView {
    
    weak var delegate: AnotherProductViewDelegate?
    
    static let hstackCellId = "hstackCellId"
    static let cellId: String = "cellId"
    static let descriptionChannel: String = "Shop Description"
    
    private enum ViewTrait {
        static let placeHolderSearch: String = .get(.findWhatYouwant)
    }
    
    private enum Section: String,CaseIterable {
        case productShop = "product"
    }
    
    lazy var searchBarImage: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        imageView.image = UIImage(named: .get(.iconSearch))
        return imageView
    }()
    
    lazy var searchBarTextField: UITextField = {
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
        containerView.addSubview(searchBarImage)
        searchBarImage.center = containerView.center
        textfield.rightView = containerView
        
        return textfield
    }()
    
    lazy var searchBarCancel: UIView = {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 40))
        let label = UILabel(frame: container.frame)
        label.text = "Cancel"
        label.textAlignment = .center
        label.font = .Roboto(.medium, size: 14)
        label.textColor = .contentGrey
        container.addSubview(label)
        label.center = container.center
        
        return container
    }()
    
    lazy var searchBar: UIStackView = {
        let container = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        container.addArrangedSubviews([searchBarTextField, searchBarCancel])
        container.axis = .horizontal
        container.spacing = 20
        
        searchBarCancel.widthAnchor.constraint(equalToConstant: 64).isActive = true
        searchBarCancel.isHidden = true

        return container
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerCustomCell(ProductCategoryItemCell.self)
        collectionView.registerXibCell(ProductViewCell.self)
        collectionView.backgroundColor = .white
        collectionView.refreshControl = refreshController
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerCustomCell(ChannelContentsHeaderCell.self)
        collectionView.registerReusableView(CustomEmptyView.self, kind: UICollectionView.elementKindSectionFooter)
        return collectionView
    }()
    
    
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
        
        searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 14, height: 40)
        
        collectionView.anchor(top: searchBarTextField.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSearchView(isEmpty: Bool){
        if isEmpty{
            searchBarImage.image = UIImage(named: .get(.iconSearch))
            searchBarCancel.isHidden = true
        } else {
            searchBarImage.image = UIImage(named: .get(.iconClose))
            searchBarCancel.isHidden = false
        }
    }
    
    @objc private func handlePullToRefresh() {
        self.delegate?.refreshUI()
    }
    
    @objc func addNewAddress() {
        delegate?.addAddress()
    }
}
