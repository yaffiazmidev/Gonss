//
//  ShortcutStoryViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 23/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShortcutStoryViewCell: UICollectionViewCell {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var addStoryIconImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addStoryIconImageView.setBorderColor = .white
        addStoryIconImageView.setBorderWidth = 1
    }

}
