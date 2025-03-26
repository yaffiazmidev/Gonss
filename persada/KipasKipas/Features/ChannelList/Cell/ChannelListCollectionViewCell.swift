//
//  ChannelListCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ChannelListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var channelIcon: UIImageView!
    @IBOutlet weak var channelTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupView(channel: ChannelsItemContent) {
        channelTitleLabel.text = channel.name
        channelIcon.loadImage(at: channel.photo)
    }
}
