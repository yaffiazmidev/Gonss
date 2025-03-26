//
//  NewChatTableViewCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 25/07/23.
//

import UIKit
import KipasKipasDirectMessage

class NewChatTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var isVerifiedIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ user: RemoteFollowingContent) {
        nameLabel.text = user.name
        userProfileImageView.loadImage(from: user.photo ?? "", placeholder: .defaultProfileImageCircle)
        isVerifiedIconImageView.isHidden = !(user.isVerified ?? false)
    }
}
