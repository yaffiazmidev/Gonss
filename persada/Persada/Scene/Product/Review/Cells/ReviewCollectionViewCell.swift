//
//  ReviewCollectionViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import Cosmos
import Kingfisher

class ReviewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var reviewLabel: ActiveLabel!
    @IBOutlet weak var mediaCollectionView: ReviewMediaCollectionView!
    @IBOutlet weak var badgeImageView: UIImageView!
    
    private var numberOfLines: Int = 0
    private var expanded: Bool = false
    private var review: String = ""
    private var textColor: UIColor = .black
    private var actionColor: UIColor = .black
    private var enableExpand: Bool = true
    var onMore: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.settings.fillMode = .precise
        reviewLabel.isHidden = true
        dividerView.isHidden = true
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.black.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
    }
    
    func setupView(_ data: ReviewItem, showMedia: Bool, numberOfLines: Int = 0, expanded: Bool = false, textColor: UIColor = .black, actionColor: UIColor = .black, enableExpand: Bool = true){
        self.numberOfLines = numberOfLines
        self.expanded = expanded
        self.textColor = textColor
        self.actionColor = actionColor
        self.enableExpand = enableExpand
        userImageView.loadImage(at: data.photo)
        userNameLabel.text = data.username
        postDateLabel.text = Date(timeIntervalSince1970: TimeInterval(data.createAt/1000)).timeAgoDisplay()
        ratingView.rating = Double(data.rating)
        
        badgeImageView.kf.indicatorType = .activity
        badgeImageView.kf.setImage(with: URL(string: data.urlBadge ?? ""))
        badgeImageView.isHidden = data.isShowBadge == false
        
        review = data.review ?? ""
        reviewLabel.text = review
        reviewLabel.isHidden = data.review.isNilOrEmpty
        setupReview()
        
        let hasMedia = data.medias?.count ?? 0 > 0
        mediaCollectionView.isHidden = !hasMedia || !showMedia
        if hasMedia && showMedia {
            if let medias = data.medias {
                mediaCollectionView.setData(medias)
            }
        }
    }
    
    func setContentInsets(_ insets: UIEdgeInsets){
        mainView.anchor(top: topAnchor, left: leftAnchor, bottom: dividerView.topAnchor, right: rightAnchor, paddingTop: insets.top, paddingLeft: insets.left, paddingBottom: insets.bottom, paddingRight: insets.right)
        
        let size = reviewLabel.frame.size
        reviewLabel.frame.size = CGSize(width: size.width - insets.left - insets.right, height: size.height - insets.top - insets.bottom)
        setupReview()
    }
    
    private func setupReview(){
        let strings = reviewLabel.getLinesArrayOfString()
        
        if !review.isEmpty && !expanded && numberOfLines > 0 && strings.count > numberOfLines{
            var visibleText = ""
            for i in 0..<numberOfLines{
                visibleText.append(strings[i])
            }
            
            var limit = visibleText.count - 12
            if limit < 0 { limit = visibleText.count - 1 }
            
            reviewLabel.setCaption(text:  review, limit: limit, moreText: "Selengkapnya", textColor: textColor, actionColor: actionColor, enableExpand: enableExpand) {
                self.onMore?()
            } lessTap: {
            }
        }
    }
}
