//
//  ReviewMediaDetailCollectionViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 25/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewMediaDetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    private let numberOfLines = 2
    var onMore: (() -> Void)?
    
    lazy var bottomView: ReviewMediaDetailBottomView = {
        let view = ReviewMediaDetailBottomView.loadViewFromNib()
        addSubview(view)
        view.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        return view
    }()

    func setupView(_ item: ReviewMedia, itemAt: Int, itemsCount: Int){
        imageView.loadImage(at: item.url)
        bottomView.pagingLabel.text = "\(itemAt + 1)/\(itemsCount)"
        bottomView.reviewCell.setupView(item.toReviewItem(), showMedia: false, numberOfLines: numberOfLines, textColor: .white, actionColor: .white, enableExpand: false)
        bottomView.reviewCell.userNameLabel.textColor = .white
        bottomView.reviewCell.reviewLabel.textColor = .white
        bottomView.reviewCell.mainView.backgroundColor = .clear
        bottomView.reviewCell.onMore = {
            self.onMore?()
        }
        
        configureCellSize(item.review ?? "")
    }
    
    private func configureCellSize(_ reviewText: String){
        let padding = UIEdgeInsets(top: 16, left: 24, bottom: 24, right: 24)
        var height: CGFloat = 64
        height += padding.top
        height += padding.bottom
        
        let spacerStackView = 5
        let contentWidth = bottomView.frame.width - padding.left - padding.right
        
        let cell = bottomView.reviewCell
        let strings = cell.reviewLabel.getLinesArrayOfString()
        
        if !reviewText.isEmpty  && numberOfLines > 0 {
            var visibleText = ""
            for i in 0..<numberOfLines{
                if i >= strings.count { break }
                visibleText.append(strings[i])
            }
            
            let reviewHeight = visibleText.height(withConstrainedWidth: contentWidth, font: .Roboto(.regular, size: 12))
            height += (CGFloat(spacerStackView) + reviewHeight)
        }else{
            let reviewHeight = reviewText.height(withConstrainedWidth: contentWidth, font: .Roboto(.regular, size: 12))
            height += (CGFloat(spacerStackView) + reviewHeight)
        }
        
        bottomView.reviewCell.setContentInsets(padding)
        bottomView.reviewView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
