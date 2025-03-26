//
//  ProductReviewView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ProductReviewView: UIView {
    @IBOutlet weak var ratingAverageLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var mediaCollectionView: ReviewMediaCollectionView!
    @IBOutlet weak var collectionView: ReviewCollectionView!
    @IBOutlet weak var seeAllButton: PrimaryButton!
    
    var handleSeeAll: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        seeAllButton.setup(color: .whiteSnow, textColor: .contentGrey, font: .Roboto(.medium, size: 16))
    }
    
    static func loadViewFromNib() -> ProductReviewView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "ProductReviewView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! ProductReviewView
    }
    
    @IBAction func seeAllAction(_ sender: UIButton) {
        self.handleSeeAll?()
    }
}
