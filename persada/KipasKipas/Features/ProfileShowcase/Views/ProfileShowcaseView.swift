//
//  ProfileShowcaseView.swift
//  KipasKipasProfileUI
//
//  Created by DENAZMI on 24/12/23.
//

import UIKit

protocol ProfileShowcaseViewDelegate: AnyObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func didSelectedProduct(by item: ShopViewModel)
}

class ProfileShowcaseView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var delegate: ProfileShowcaseViewDelegate?
    
    var productItems: [ShopViewModel] = [] {
        didSet {
            collectionView.isHidden = productItems.isEmpty
//            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerXibCell(ShopProductCollectionViewCell.self)
        setupPinterestLayout()
    }
    
    private func setupPinterestLayout() {
        let layout = DENCollectionViewLayout()
        layout.minimumColumnSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.columnCount = 2
        layout.sectionInset = .init(horizontal: 6, vertical: 6)
        collectionView.collectionViewLayout = layout
    }
}

extension ProfileShowcaseView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShopProductCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setupViewForShop(productItems[indexPath.item])
        cell.discountPriceContainerStackView.isHidden = true
        return cell
    }
}

extension ProfileShowcaseView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectedProduct(by: productItems[indexPath.item])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
}

extension ProfileShowcaseView: DENCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width / 3 - 1, height: 160)
        guard !productItems.isEmpty else { return CGSize() }
        let item = productItems[indexPath.item]
        let heightImage = item.metadataHeight ?? 1028
        let widthImage = item.metadataWidth ?? 1028
        let width = collectionView.frame.size.width - 4
        let scaler = width / widthImage
        let percent = Double((10 - ((indexPath.item % 3) + 1))) / 10
        var height = heightImage * scaler
        if height > 500 {
            height = 500
        }
        height = (height * percent) + 200
        return CGSize(width: width, height: height)
    }
}
