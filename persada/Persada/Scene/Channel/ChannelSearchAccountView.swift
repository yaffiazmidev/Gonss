//
//  ChannelSearchAccountView.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class ChannelSearchAccountView: UIView {
	
	lazy var collectionView: UICollectionView = {
		let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        
        view.registerCustomReusableHeaderView(ChannelHeaderView.self)
        view.registerCustomCell(ChannelSearchAccountCell.self)
        
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
    
    func emptyView(_ text: String?) -> ChannelEmptyView {
        let view = ChannelEmptyView()
        view.setText(text ?? "")
        return view
    }
}
