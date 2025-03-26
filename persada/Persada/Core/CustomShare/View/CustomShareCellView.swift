//
//  CustomShareCellView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 22/10/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

class CustomShareCellView : UICollectionViewCell {
    
    @IBOutlet weak var imageViewActionIcon: UIImageView!
    @IBOutlet weak var labelActionName: UILabel!
    
    var data : CustomShareModel? {
        didSet {
            if let value = data {
                imageViewActionIcon.image = value.icon
                labelActionName.text = value.title
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
        labelActionName.sizeToFit()
    }

}
