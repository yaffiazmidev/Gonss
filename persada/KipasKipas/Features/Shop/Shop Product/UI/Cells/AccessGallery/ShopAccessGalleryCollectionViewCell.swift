//
//  ShopAccessGalleryCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 27/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ShopAccessGalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var closeNotifStackView: UIStackView!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var activeGalleryButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        privacyPolicyLabel.underline()
    }

}
