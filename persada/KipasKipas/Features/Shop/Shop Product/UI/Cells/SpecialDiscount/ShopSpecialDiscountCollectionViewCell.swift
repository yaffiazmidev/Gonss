//
//  ShopSpecialDiscountCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 01/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShopSpecialDiscountCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    private var specialDiscountCountdown = CountdownManager(
        notificationCenter: NotificationCenter.default,
        willResignActive: UIApplication.willResignActiveNotification,
        willEnterForeground: UIApplication.willEnterForegroundNotification
    )
    
    var products: [RemoteProductEtalaseData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var handleClickDetailProduct: ((RemoteProductEtalaseData) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView.loadImage(at: "https://asset.kipaskipas.com/assets_public/mobile/ios/shop/bg_slider_1.png", .w720)
        setupCollectionView()
        specialDiscountCountdown = CountdownManager(
            notificationCenter: NotificationCenter.default,
            willResignActive: UIApplication.willResignActiveNotification,
            willEnterForeground: UIApplication.willEnterForegroundNotification
        )
        specialDiscountCountdown.delegate = self
        specialDiscountCountdown.stopTimer()
        specialDiscountCountdown.startTimer(timeLeft: Date().remainingSecondsBeforeNoon ?? 0)
    }
    
    deinit {
        specialDiscountCountdown.stopTimer()
        specialDiscountCountdown.removeObserver()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 11.5, left: 144, bottom: 11.5, right: 11.5)
        collectionView.registerXibCell(ShopSpecialDiscountItemCollectionViewCell.self)
    }
}

extension ShopSpecialDiscountCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleClickDetailProduct?(products[indexPath.item])
    }
}

extension ShopSpecialDiscountCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ShopSpecialDiscountItemCollectionViewCell.self, for: indexPath)
        cell.setupView(item: products[indexPath.item])
        return cell
    }
}

extension ShopSpecialDiscountCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: collectionView.frame.height - (11.5 * 2))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension ShopSpecialDiscountCollectionViewCell: CountdownManagerDelegate {
    func didChangeCountdown(count: Int) {
        countdownLabel.text = secondsToHoursMinutesSeconds(totalSeconds: count)
    }
    
    func didFinishCountdown() {
        print("asdasfasgfasklhakgjaskgbkjlasbgkjlasblgkbanslkgsa")
    }
    
    func secondsToHoursMinutesSeconds(totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d : %02d : %02d", hours, minutes, seconds)
    }
}
