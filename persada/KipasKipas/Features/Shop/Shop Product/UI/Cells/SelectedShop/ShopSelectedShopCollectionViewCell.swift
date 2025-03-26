//
//  ShopSelectedShopCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 02/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShopSelectedShopCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var stores: [RemoteStoreItemData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var handleDidSelecStore: ((RemoteStoreItemData?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 0, left: 13, bottom: 0, right: 13)
        collectionView.registerXibCell(ShopSelectedShopItemCollectionViewCell.self)
    }
}



extension ShopSelectedShopCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stores.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShopSelectedShopItemCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setupView(item: stores[indexPath.item])
        return cell
    }
}

extension ShopSelectedShopCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleDidSelecStore?(stores[indexPath.item])
    }
}

extension ShopSelectedShopCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2.9), height: collectionView.frame.height)
    }
}
