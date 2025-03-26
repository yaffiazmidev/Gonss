//
//  ChannelContentsHeaderCollectionReusableView.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

class ChannelContentsHeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var channelDescriptionLabel: UILabel!
    @IBOutlet weak var followButton: KKLoadingButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupFollowingButtonStatus(isFollow: Bool) {
        followButton.setTitleColor(isFollow ? .black : .white, for: .normal)
        followButton.setTitle(isFollow ? "Unfollow" : "Follow")
        followButton.bgColor = isFollow ? .whiteSnow : .primary
    }
}
