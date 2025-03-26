//
//  ShopBannerCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 01/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShopBannerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var banners: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageControl.numberOfPages = banners.count
        pageControl.currentPage = 0
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerXibCell(ShopBannerItemCollectionViewCell.self)
        startInfinityScroll(animationDelay: 5)
    }
    
    func startInfinityScroll(animationDelay: TimeInterval = 3) {
        var currentIndex = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.timer = Timer.scheduledTimer(withTimeInterval: animationDelay, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                
                self.collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: currentIndex == 0 ? false : true)
                currentIndex = (currentIndex + 1) % banners.count
            }
        }
    }
}

extension ShopBannerCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
}

extension ShopBannerCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ShopBannerItemCollectionViewCell.self, for: indexPath)
        cell.bannerImageView.loadImage(at: banners[indexPath.item], .w720)
        return cell
    }
}

extension ShopBannerCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
        
    }
}
