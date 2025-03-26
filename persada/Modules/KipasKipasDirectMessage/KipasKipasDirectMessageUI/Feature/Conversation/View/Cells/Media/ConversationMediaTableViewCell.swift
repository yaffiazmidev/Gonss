//
//  ConversationMediaTableViewCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 30/07/23.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasShared
import SDWebImage

class ConversationMediaTableViewCell: UITableViewCell, Accessible {
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var mediaComponentStackView: UIStackView!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var iconPlayMediaImageView: UIImageView!
    
    @IBOutlet weak var mediaSendingDateLabel: UILabel!
    @IBOutlet weak var mediaSendingStatusIconImageView: UIImageView!
    @IBOutlet weak var increaseDiamondContainerStackView: UIStackView!
    @IBOutlet weak var diamondPriceLabel: UILabel!
    @IBOutlet weak var decreaseCoinContainerStackView: UIStackView!
    @IBOutlet weak var coinPriceLabel: UILabel!
    
    @IBOutlet weak var mediaHeightConstraint: NSLayoutConstraint!
    
    var handleSelectedMedia: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        generateAccessibilityIdentifiers()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = UIImage.set("empty")
    }
    
    func configure(with message: TXIMMessage, selecting: Bool) {
        updateMessageStatus(message)
        defaultMessageLayout(isSender: message.isSelf)
        
        let isVideo = message.type == .video
        let imagePath = isVideo == true ? message.snapshotPath : message.imagePath
        let imageUrl = isVideo == true ? message.snapshotUrl : message.thumnailImageUrl
        
        var url: URL? = nil
        if let path = imagePath, FileManager.default.fileExists(atPath: path) {
            url = URL(fileURLWithPath: path)
        } else {
            url = URL(string: imageUrl ?? "")
        }
        updateMediaContainerView(isVideo: isVideo)
        iconPlayMediaImageView.isHidden = !isVideo
        
        let defaultPlaceholder = UIImage.set("empty")
        thumbnailImageView.sd_setImage(with: url, placeholderImage: defaultPlaceholder)
        
        mediaSendingDateLabel.text = message.timestamp.sbu_toString(format: .HHmm)
        increaseDiamondContainerStackView.isHidden = true
        decreaseCoinContainerStackView.isHidden = true
        contentView.backgroundColor = .clear
    }
    
    func updateMessageStatus(_ message: TXIMMessage) {
        switch message.status {
        case .sending:
            mediaSendingStatusIconImageView.image = UIImage.set("ic_clock_gray")
        case .send_succ:
            mediaSendingStatusIconImageView.image = UIImage.set("ic_check_double_grey")
        case .send_fail:
            mediaSendingStatusIconImageView.image = UIImage.set("ic_arrow_rotate_right_red")
        default:
            mediaSendingStatusIconImageView.image = UIImage.set("ic_clock_gray")
        }
        if message.isRead {
            mediaSendingStatusIconImageView.image = UIImage.set("ic_check_double_blue")
        }
    }
    
    private func updateMediaContainerView(isVideo: Bool) {
//        mediaHeightConstraint.constant = isVideo ? 133 : 249
//        layoutIfNeeded()
    }
    
    func defaultMessageLayout(isSender: Bool) {
        containerStackView.alignment = isSender ? .trailing : .leading
        mediaComponentStackView.backgroundColor = UIColor(hexString: isSender ? "#E1FED3" : "#F9F9F9")
        mediaSendingStatusIconImageView.isHidden = !isSender
    }
}
