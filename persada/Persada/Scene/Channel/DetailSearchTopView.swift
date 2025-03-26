//
//  DetailSearchTopView.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol DetailSearchTopViewDelegate where Self: UIViewController {
	
}

final class DetailSearchTopView: UIView {
	
	weak var delegate: DetailSearchTopViewDelegate?
	
	static let cellId: String = "cellId"
	
	lazy var collectionView: UICollectionView = {
		let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		view.register(DetailSearchTopItemCell.self, forCellWithReuseIdentifier: DetailSearchTopView.cellId)
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		addSubview(collectionView)
		collectionView.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
