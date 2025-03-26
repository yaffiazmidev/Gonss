//
//  ReviewMediaCollectionViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 14/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import Cosmos

class ReviewMediaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var ratingDateView: UIStackView!
    @IBOutlet weak var anotherView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.settings.fillMode = .precise
    }
    
    func setupView(_ data: ReviewMedia, showRatingDate: Bool = false, showAnother: Bool = false){
        imageView.loadImage(at: data.url)
        ratingDateView.isHidden = !showRatingDate
        anotherView.isHidden = !showAnother
        if showRatingDate {
            ratingView.rating = Double(data.rating)
            postDateLabel.text = Date(timeIntervalSince1970: TimeInterval(data.createAt/1000)).timeAgoDisplay()
        }
    }
    
    func setupImageConstraints(_ size: CGFloat){
        imageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: size).isActive = true
    }
}
