//
//  ContentSettingSection2Cell.swift
//  KipasKipas
//
//  Created by DENAZMI on 15/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ContentSettingSection2Cell: UITableViewCell {
    
    @IBOutlet weak var iconChevronContainerStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupView(iconImage: UIImage?, title: String) {
        itemImageView.image = iconImage
        titleLabel.text = title
    }
}
