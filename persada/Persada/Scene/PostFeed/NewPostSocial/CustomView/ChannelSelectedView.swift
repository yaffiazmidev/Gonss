//
//  ChannelSelectedView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 12/08/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ChannelSelectedView: UITableViewCell {

    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var channelImage: UIImageView!
    
    var onCloseChannelClicked = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        layer.cornerRadius = 8
        isUserInteractionEnabled = true
        channelName.font = .Roboto(.medium, size: 16)
        channelImage.layer.cornerRadius = 6
        channelImage.contentMode = .scaleAspectFill
    }
    
    func setupData(channel: Channel) {
        if let url = channel.photo {
            channelImage.loadImage(at: url)
        }
        channelName.text = channel.name?.uppercased()
    }

    @IBAction func onCloseChannelClick(_ sender: UIButton) {
        onCloseChannelClicked()
    }
}
