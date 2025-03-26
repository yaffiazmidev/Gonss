//
//  ContentSettingFollowingTableViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 22/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import Kingfisher

class ContentSettingFollowingTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sendButtonContainetStackView: UIStackView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var sendButtonTitleLabel: UILabel!
    
    var alreadySendToUser: Bool = false {
        didSet {
            sendButtonTitleLabel.text = alreadySendToUser ? "Sent!" : "Send"
            sendButtonTitleLabel.textColor = alreadySendToUser ? .contentGrey : .white
            sendButtonContainetStackView.backgroundColor = alreadySendToUser ? .whiteSmoke : .primary
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupView(item: RemoteFollowingContent) {
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: URL(string: item.photo ?? ""), placeholder: UIImage.defaultProfileImageCircle)
        
        usernameLabel.text = item.name ?? ""
    }
}
