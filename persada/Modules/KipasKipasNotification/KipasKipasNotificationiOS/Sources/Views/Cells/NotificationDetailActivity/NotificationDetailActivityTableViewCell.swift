//
//  NotificationDetailActivityTableViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 05/04/24.
//

import UIKit

class NotificationDetailActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var valueCommentLabel: UILabel!
    
    var didCLickThumbnail: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let onTapThumbnailImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapThumbnailImageViewGesture))
        thumbnailImageView.isUserInteractionEnabled = true
        thumbnailImageView.addGestureRecognizer(onTapThumbnailImageViewGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        valueCommentLabel.text = nil
        didCLickThumbnail = nil
        thumbnailImageView.cancelLoad()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func handleOnTapThumbnailImageViewGesture() {
        didCLickThumbnail?()
    }
}
