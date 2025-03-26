//
//  ShopProductRecomCollectionViewCell.swift
//  Countdown
//
//  Created by DENAZMI on 19/01/23.
//

import UIKit

class ShopProductRecomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var emptyProductLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var products: [RecommendShopViewModel] = [] {
        didSet {
            emptyProductLabel.isHidden = !products.isEmpty
            collectionView.isHidden = products.isEmpty
            collectionView.reloadData()
        }
    }
        
    var handleClickDetailRecommend: ((RecommendShopViewModel) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerXibCell(ShopProductRecomItemCollectionViewCell.self)
    }

}

extension ShopProductRecomCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = products[indexPath.item]
        handleClickDetailRecommend?(item)
    }
}

extension ShopProductRecomCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ShopProductRecomItemCollectionViewCell.self, for: indexPath)
        let item = products[indexPath.item]
//        cell.productImageView.loadImage(at: item.imageURL)
//        cell.productTitleLabel.text = item.name
        cell.setupView(item)
        return cell
    }
}

extension ShopProductRecomCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.5, height: collectionView.frame.height)
    }
}
