//
//  NotificationActivityEmptyTableViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 20/03/24.
//

import UIKit
import KipasKipasShared

class NotificationActivityEmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var emptyImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        emptyImageView.image = .imageNoActivityOutlineGrey
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
