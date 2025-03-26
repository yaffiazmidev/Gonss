//
//  NotificationLastActivityTableViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 19/03/24.
//

import UIKit

class NotificationLastActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var followButtonLabel: UILabel!
    @IBOutlet weak var messageButtonLabel: UILabel!
    @IBOutlet weak var bottomRightIcon1ImageView: UIImageView!
    @IBOutlet weak var bottomRightIcon2ImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        followButtonLabel.clipsToBounds = true
        messageButtonLabel.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
