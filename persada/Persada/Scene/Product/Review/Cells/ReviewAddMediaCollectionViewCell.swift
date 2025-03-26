//
//  ReviewAddMediaCollectionViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 01/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewAddMediaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var addView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetView()
    }
    
    func setupView(_ media: ReviewAddMedia){
        addView.isHidden = true
        if let media = media.media {
            imageView.loadImage(at: media.url)
            imageView.isHidden = false
            closeView.isHidden = false
        }else {
            loadingView.isHidden = false
            loadingView.startAnimating()
        }
    }
    
    func resetView(){
        addView.isHidden = false
        imageView.image = nil
        imageView.isHidden = true
        closeView.isHidden = true
        loadingView.isHidden = true
    }
}
