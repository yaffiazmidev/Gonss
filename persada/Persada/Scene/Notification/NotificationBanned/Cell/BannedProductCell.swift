//
//  BannedProductCell.swift
//  KipasKipas
//
//  Created by koanba on 05/08/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class BannedProductCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.width / 9
    }
    
    func setup(medias: Medias) {
        imageView.setImage(url: medias.thumbnail?.small ?? "")
    }

}
