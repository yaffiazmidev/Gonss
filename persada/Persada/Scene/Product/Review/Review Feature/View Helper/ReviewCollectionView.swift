//
//  ReviewCollectionView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewCollectionView: UICollectionView{
    private var reviews: [ReviewItem]!
    private var ratingAverage: Double?
    private var ratingCount: Int?
    private var reviewCount: Int?
    var withHeader: Bool = false
    var showDivider: Bool = false
    var showMedia: Bool = true
    var viewInsets: UIEdgeInsets = UIEdgeInsets.zero
    var numberOfLines: Int = 4
    private var expandeds: [Bool] = []
    
    var handleItemTapped: ((_ item: ReviewItem) -> Void)?
    var handleMediaItemTapped: ((_ item: ReviewItem, _ media: ReviewMedia, _ atMedia: Int) -> Void)?
    var handleHeightUpdated: (() -> Void)?
    var handleScrollViewDidScroll: ((UIScrollView) -> Void)?
    
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
        self.registerXibCell(ReviewHeaderCollectionViewCell.self, kind: UICollectionView.elementKindSectionHeader)
        self.registerXibCell(ReviewCollectionViewCell.self)
        self.setData([])
    }
    
    func setData(_ items: [ReviewItem], ratingAverage: Double? = nil, ratingCount: Int? = nil, reviewCount: Int? = nil){
        self.reviews = items
        self.expandeds.removeAll()
        items.forEach { _ in
            self.expandeds.append(false)
        }
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        self.reviewCount = reviewCount
        self.reloadData()
    }
}

extension ReviewCollectionView: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.handleItemTapped?(reviews[indexPath.row])
    }
}

extension ReviewCollectionView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ReviewCollectionViewCell.self, for: indexPath)
        let index = indexPath.row
        let item = reviews[index]
        cell.setupView(item, showMedia: showMedia, numberOfLines: numberOfLines, expanded: expandeds[index])
        cell.setContentInsets(viewInsets)
        cell.onMore = {
            self.expandeds[index] = true
            collectionView.reloadItems(at: [indexPath])
            self.handleHeightUpdated?()
        }
        cell.dividerView.isHidden = !showDivider
        cell.mediaCollectionView.handleItemTapped = { media, at in
            self.handleMediaItemTapped?(item, media, at)
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleScrollViewDidScroll?(scrollView)
    }
}

extension ReviewCollectionView: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = reviews[indexPath.row]
        let hasMedia = item.medias?.count ?? 0 > 0
        var height: CGFloat = 64
        height += viewInsets.top
        height += viewInsets.bottom
        if hasMedia && showMedia {
            height += 70
        }
        
        
        if !item.review.isNilOrEmpty{
            let spacerStackView = 5
            let contentWidth = collectionView.frame.width - viewInsets.left - viewInsets.right
            let text = reviews[indexPath.row].review ?? ""
            
            let nib = UINib(nibName: "ReviewCollectionViewCell", bundle: nil)
            let cell = nib.instantiate(withOwner: self, options: nil).first as! ReviewCollectionViewCell
            let label = cell.reviewLabel!
            label.text = text
            let strings = label.getLinesArrayOfString()
            
            if !text.isEmpty && !expandeds[indexPath.row] && numberOfLines > 0 && strings.count > numberOfLines {
                label.text = text
                var visibleText = ""
                for i in 0..<numberOfLines{
                    visibleText.append(strings[i])
                }
                
                let reviewHeight = visibleText.height(withConstrainedWidth: contentWidth, font: .Roboto(.regular, size: 12))
                height += (CGFloat(spacerStackView) + reviewHeight)
            }else {
                let reviewHeight = text.height(withConstrainedWidth: contentWidth, font: .Roboto(.regular, size: 12))
                height += (CGFloat(spacerStackView) + reviewHeight)
            }
        }
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: withHeader ? 74 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let cell = collectionView.dequeueReusableSupplementaryCell(ReviewHeaderCollectionViewCell.self, for: indexPath, kind: UICollectionView.elementKindSectionHeader)
            cell.updateView(ratingAverage: ratingAverage ?? 0.0, ratingCount: ratingCount ?? 0, reviewCount: reviewCount ?? 0)
            return cell
        default: assert(false, "Unexpected element kind")
        }
    }
}
