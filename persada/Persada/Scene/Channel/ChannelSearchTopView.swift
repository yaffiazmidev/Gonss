//
//  ChannelSearchTopView.swift
//  Persada
//
//  Created by NOOR on 24/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit


final class ChannelSearchTopView: UIView {
    
    private lazy var flowLayout: DENCollectionViewLayout = {
        let layout = DENCollectionViewLayout()
        layout.columnCounts = [1, 1, 3]
        layout.minimumColumnSpacings = [12, 0, 5]
        layout.minimumInteritemSpacings = [12, 0, 5]
        layout.headerHeights = [0, 0, 0]
        layout.footerHeights = [0, 0, 0]
        layout.sectionInsets = [
            .init(horizontal: 16, vertical: 0),
            .init(top: 16, left: 0, bottom: 0, right: 0),
            .init(horizontal: 8, vertical: 0)
        ]
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        
        view.registerCustomReusableHeaderView(ChannelHeaderView.self)
        view.registerCustomCell(ChannelSearchAccountCell.self)
        view.registerCustomReusableFooterView(ChannelSearchTopFooterView.self)
        view.registerCustomCell(ChannelSearchTopDividerViewCell.self)
        view.registerCustomCell(ChannelSearchTopItemCell.self)
        
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
    
    
    func updateKind(_ datasource: ChannelSearchTopModel.DataSource){
        let feedCount = datasource.feeds?.count ?? 0
        flowLayout.headerHeights![2] = (feedCount == 0) ? 0 : 48
        
        let accountCount = datasource.accounts?.count ?? 0
        flowLayout.headerHeights![0] = (accountCount == 0) ? 0 : 48
        flowLayout.footerHeights![0] = (accountCount <= 4) ? 0 : 40
    }
    
    func emptyView(_ text: String?) -> ChannelEmptyView {
        let view = ChannelEmptyView()
        view.setText(text ?? "")
        return view
    }
}
