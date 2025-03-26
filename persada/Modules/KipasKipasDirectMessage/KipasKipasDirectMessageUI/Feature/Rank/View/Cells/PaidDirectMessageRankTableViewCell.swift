//
//  PaidDirectMessageRankTableViewCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 05/08/23.
//

import UIKit
import KipasKipasDirectMessage

class PaidDirectMessageRankTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var chatReplyCountLabel: UILabel!
    @IBOutlet weak var rankNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(user: RemoteChatRankData) {
        profileImageView.loadImage(from: user.photo)
        usernameLabel.text = user.name ?? ""
        chatReplyCountLabel.text = "\(user.chatReplyCount ?? 0) dibalas"
    }
}
