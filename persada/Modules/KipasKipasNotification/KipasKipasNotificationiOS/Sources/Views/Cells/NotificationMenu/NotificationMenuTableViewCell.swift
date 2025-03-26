//
//  NotificationMenuTableViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 19/03/24.
//

import UIKit

class NotificationMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageVIew: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var redDotView: UIView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var unreadCountStack: UIStackView!
    @IBOutlet weak var chevronRightContainerStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageVIew.image = nil
        titleLabel.text = nil
        valueLabel.text = nil
        dateLabel.text = nil
        unreadCountLabel.text = nil
        dateLabel.isHidden = true
        redDotView.isHidden = true
        unreadCountStack.isHidden = true
        chevronRightContainerStack.isHidden = true
    }

    func setupView(item: NotificationMenuItem) {
        iconImageVIew.image = item.menu.icon
        titleLabel.text = item.menu.title
        valueLabel.text = item.value
        dateLabel.text = "• \(item.date)"
        dateLabel.isHidden = item.date.isEmpty
        
        
        switch item.menu {
        case .newFollowers:
            unreadCountStack.isHidden = item.unreadCount <= 0
            unreadCountLabel.text = item.unreadCount.formatViews()
            chevronRightContainerStack.isHidden = !unreadCountStack.isHidden
        case .activities:
            unreadCountStack.isHidden = item.unreadCount <= 0
            unreadCountLabel.text = item.unreadCount.formatViews()
            chevronRightContainerStack.isHidden = !unreadCountStack.isHidden
        case .systemNotifications:
            redDotView.isHidden = item.isRead
            chevronRightContainerStack.isHidden = !item.isRead
        case .transaksi:
            redDotView.isHidden = item.isRead
            chevronRightContainerStack.isHidden = !item.isRead
        }
    }
    
}
