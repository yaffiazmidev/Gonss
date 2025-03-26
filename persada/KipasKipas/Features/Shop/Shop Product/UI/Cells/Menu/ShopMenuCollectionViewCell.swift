//
//  ShopMenuCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 01/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShopMenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var categories: [CategoryShopItem] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var handleClickAllCategory: (() -> Void)?
    var handleClickDetailCategory: ((CategoryShopItem) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 12, left: 8, bottom: 12, right: 8)
        collectionView.registerXibCell(ShopMenuItemCollectionViewCell.self)
    }
}

extension ShopMenuCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: ShopMenuItemCollectionViewCell.self, indexPath: indexPath)
        let item = categories[indexPath.item]
        cell.titleLabel.text = item.name
        if item.name == "Lihat Semua" {
            cell.iconImageView.image = UIImage(named: "ic_view_all")
        } else {
            cell.iconImageView.loadImageWithoutOSS(at: item.icon)
        }
        
        return cell
    }
}

extension ShopMenuCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = categories[indexPath.row]
        indexPath.row == categories.count - 1 ? handleClickAllCategory?() : handleClickDetailCategory?(item)
    }
}

extension ShopMenuCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dividerWidth = 4
        let numberOfItemsInRow = 6
        let numberOfDividers = numberOfItemsInRow - 1
        let totalSpacing = dividerWidth * numberOfDividers // Adjust the spacing value as needed
        
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - CGFloat(totalSpacing)) / CGFloat(numberOfItemsInRow)
        
        return CGSize(width: cellWidth - 2.6, height: 74)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
