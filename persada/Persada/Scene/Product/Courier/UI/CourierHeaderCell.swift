//
//  CourierHeaderCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class CourierHeaderCell: UICollectionReusableView {
    
    private enum ViewTrait {
        static let padding: CGFloat = 16
    }
    
    var name: String? {
        didSet {
            if name == String.get(.anteraja){
                imageHeader.image = UIImage(named: .get(.iconAnterAja))
            } else if name == String.get(.sicepat) {
                imageHeader.image = UIImage(named: .get(.iconSicepat))
            } else if name == String.get(.jnt) {
                imageHeader.image = UIImage(named: .get(.iconJNT))
            }
        }
    }
    
    lazy var imageHeader : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.clipsToBounds = true
        image.contentMode = .left
        image.isUserInteractionEnabled = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = false
        return image
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        addSubview(imageHeader)
        
        imageHeader.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
