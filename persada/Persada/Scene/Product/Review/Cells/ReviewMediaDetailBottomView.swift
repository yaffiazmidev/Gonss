//
//  ReviewMediaDetailBottomView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 25/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewMediaDetailBottomView: UIView {
    
    @IBOutlet weak var pagingLabel: UILabel!
    @IBOutlet weak var reviewView: UIView!
    
    lazy var reviewCell: ReviewCollectionViewCell = {
        let nib = UINib(nibName: "ReviewCollectionViewCell", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! ReviewCollectionViewCell
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewView.addSubview(reviewCell)
        reviewCell.fillSuperview()
    }
    
    static func loadViewFromNib() -> ReviewMediaDetailBottomView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "ReviewMediaDetailBottomView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! ReviewMediaDetailBottomView
    }
    
}


