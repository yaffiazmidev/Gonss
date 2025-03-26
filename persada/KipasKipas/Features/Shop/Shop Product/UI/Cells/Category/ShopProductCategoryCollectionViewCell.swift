//
//  ShopProductCategoryCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 27/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ShopProductCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var categories: [CategoryShopItem] = [] {
        didSet {
            if selectedCategory == nil {
                selectedCategory = categories.first
            }
            
            collectionView.reloadData()
        }
    }
    
    var selectedCategory: CategoryShopItem?
        
    var handleClickAllCategory: (() -> Void)?
    var handleClickDetailCategory: ((CategoryShopItem) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.registerXibCell(ShopProductCategoryItemCollectionViewCell.self)
    }
}

extension ShopProductCategoryCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = categories[indexPath.row]
        selectedCategory = item
        collectionView.reloadData()
    }
}

extension ShopProductCategoryCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShopProductCategoryItemCollectionViewCell = collectionView.dequeueReusableCell(at: indexPath)
        let item = categories[indexPath.item]
        cell.categoryLabel.text = item.name
        cell.isSelectedCategory = selectedCategory?.id == item.id
        return cell
    }
}

extension ShopProductCategoryCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let categoryName = categories[indexPath.item].name
        let label = UILabel()
        label.text = categoryName
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.sizeToFit()
        let width = label.frame.width + 16 // Add padding
        return CGSize(width: width, height: 40) // Adjust the height according to your requirements
    }
}
