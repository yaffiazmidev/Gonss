//
//  StoryCollectionTableViewCell.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 14/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class StoryCollectionTableViewCell: UITableViewCell {

	let collectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .white
		collectionView.register(StoryItemCell.self, forCellWithReuseIdentifier: BaseFeedView.storyCellId)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.allowsMultipleSelection = true
		return collectionView
	}()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
			contentView.addSubview(collectionView)
			collectionView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
