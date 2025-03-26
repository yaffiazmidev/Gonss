//
//  AddProductResellerView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ResellerProductSelectView: UIView {
    lazy var refreshController: UIRefreshControl = {
        let refresh = UIRefreshControl(backgroundColor: .white)
        refresh.tintColor = .primary
        return refresh
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.refreshControl = refreshController
        view.showsVerticalScrollIndicator = false
        view.contentInset = .init(all: 8)
        view.registerReusableView(ResellerProductSelectHeaderCell.self, kind: UICollectionView.elementKindSectionHeader)
        view.registerCustomCell(ResellerProductSelectItemCell.self)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(collectionView)
        collectionView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
