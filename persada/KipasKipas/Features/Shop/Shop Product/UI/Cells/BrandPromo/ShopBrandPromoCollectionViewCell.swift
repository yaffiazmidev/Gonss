//
//  ShopBrandPromoCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 02/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShopBrandPromoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var brands: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.registerXibCell(ShopBrandPromoItemCollectionViewCell.self)
    }
}



extension ShopBrandPromoCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brands.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShopBrandPromoItemCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.brandImageView.loadImage(at: brands[indexPath.item], .w720)
        return cell
    }
}

extension ShopBrandPromoCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ShopBrandPromoCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2.8) - 6, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}
