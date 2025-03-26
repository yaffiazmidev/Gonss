//
//  ReviewMediaCollectionView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewMediaCollectionView: UICollectionView{
    private var medias: [ReviewMedia]!
    var showAnotherView: Bool = false
    var showRatingDate: Bool = false
    
    var cellSize: CGSize = CGSize.zero
    var handleItemTapped: ((_ item: ReviewMedia, _ at: Int) -> Void)?
    var handleHeightUpdated: ((CGFloat) -> Void)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup(){
        self.backgroundColor = .white
        self.delegate = self
        self.dataSource = self
        self.registerXibCell(ReviewMediaCollectionViewCell.self)
        self.setData([])
    }
    
    func setData(_ items: [ReviewMedia]){
        medias = items
        self.reloadData()
    }
}

extension ReviewMediaCollectionView: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.handleItemTapped?(medias[indexPath.row], indexPath.row)
    }
}

extension ReviewMediaCollectionView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ReviewMediaCollectionViewCell.self, for: indexPath)
        let isLast = indexPath.row == 4
        cell.setupView(medias[indexPath.row], showAnother: showAnotherView && isLast)
        return cell
    }
}

extension ReviewMediaCollectionView: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size =  (collectionView.frame.width - 32) / 5
        handleHeightUpdated?(size)
        cellSize = CGSize(width: size, height: size)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
