//
//  ReviewMediaDetailCaptionView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 02/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewMediaDetailCaptionView: UIView{
    lazy var pillView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteSmoke
        view.clipsToBounds = true
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var reviewCell: ReviewCollectionViewCell = {
        let nib = UINib(nibName: "ReviewCollectionViewCell", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! ReviewCollectionViewCell
    }()
    
    lazy var reviewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reviewCell)
        reviewCell.fillSuperview()
        reviewCell.setContentInsets(UIEdgeInsets(all: 20))
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
