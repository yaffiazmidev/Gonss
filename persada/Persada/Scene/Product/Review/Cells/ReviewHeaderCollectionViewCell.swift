//
//  ReviewHeaderCollectionViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewHeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ratingAverageLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateView(ratingAverage: Double, ratingCount: Int, reviewCount: Int){
        ratingAverageLabel.text = "\(ratingAverage)"
        ratingCountLabel.text = "\(ratingCount) rating"
        reviewCountLabel.text = "\(reviewCount) ulasan"
    }
}
