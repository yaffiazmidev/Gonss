//
//  ChatTableViewCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 14/07/23.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasShared
import SDWebImage

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var pinImageV: UIImageView!
    
    @IBOutlet weak var lastMessageIconImageView: UIImageView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var unReadMessageCountLabel: UILabel!
    @IBOutlet weak var unReadMessageCountView: UIView!
    @IBOutlet weak var isVerifiedImageView: UIImageView!
    @IBOutlet weak var coinIconImageView: UIImageView!
    @IBOutlet weak var unreadMsgViewW: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(hexString: "#FFFFFF")
    }
     
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lastMessageLabel.text = nil
        userFullNameLabel.text = nil
        lastMessageDateLabel.text = nil
        userProfileImageView.image = nil
        unReadMessageCountLabel.text = nil
        lastMessageIconImageView.image = nil
        coinIconImageView.isHidden = true
        isVerifiedImageView.isHidden = true
        unReadMessageCountLabel.isHidden = true
    }
    
    func configureData(_ conversation: TXIMConversation, isVerified: Bool, isPaid: Bool) {
        isVerifiedImageView.isHidden = !isVerified
        
        userFullNameLabel.text = conversation.nickName
        
        userProfileImageView.sd_setImage(with: URL(string: conversation.faceURL), placeholderImage: .defaultProfileImageCircle)
        let unreadMessageCount = Int(conversation.unreadCount)
        updateUnReadCount(unreadMessageCount)
        
        setupLastMessage(type: conversation.lastMsgType, timestamp: conversation.lastMsgTimestamp, text: conversation.text, isRevoke: conversation.isLastMsgRevoke, isSelf: conversation.isLastMsgSelf)
        lastMessageDateLabel.textColor = unreadMessageCount <= 0 ? UIColor(hexString: "#8A8A8A") : .systemBlue
        
        contentView.backgroundColor = UIColor(hexString: "#FFFFFF")
        
        coinIconImageView.isHidden = true//!isPaid
        userProfileImageView.layer.borderColor = UIColor.clear.cgColor//isPaid ? UIColor(hexString: "#FF8A00").cgColor : UIColor.clear.cgColor
        
        if conversation.isUnread && unreadMessageCount <= 0 {
            unReadMessageCountView.isHidden = false
            unreadMsgViewW.constant = 11
            unReadMessageCountView.layer.cornerRadius =  11/2
            lastMessageDateLabel.textColor =  .systemBlue
        }else{
            unreadMsgViewW.constant = 22
            unReadMessageCountView.layer.cornerRadius =  11
        }
        pinImageV.isHidden = !conversation.isPin
    }
    
    private func updateUnReadCount(_ count: Int) {
        unReadMessageCountView.isHidden = count <= 0
        unReadMessageCountLabel.isHidden = count <= 0
        unReadMessageCountLabel.text = "\(count.formatViews())"
        
        let width = unReadMessageCountLabel.intrinsicContentSize.width
        if width > 18 {
            unReadMessageCountLabel.font = unReadMessageCountLabel.font.withSize(width > 26 ? 10 : 12)
        }
         
    }
    
    private func setupLastMessage(type: TXIMMessageType, timestamp: Date?, text: String?, isRevoke: Bool, isSelf: Bool) {
        lastMessageDateLabel.text = ""
        lastMessageLabel.text = ""
        guard let timestamp else {
            lastMessageDateLabel.text = ""
            lastMessageLabel.text = ""
            return
        }
        
        lastMessageDateLabel.text = "\(timestamp.timeAgoDisplay())"
        
        if isRevoke {
            lastMessageIconImageView.isHidden = true
            let text = isSelf ? "Kamu menarik kembali pesan" : "Dia menarik kembali pesan"
            lastMessageLabel.text = text
        } else {
            switch type {
            case .text:
                lastMessageIconImageView.isHidden = true
                lastMessageLabel.text = text
            case .image:
                lastMessageIconImageView.isHidden = false
                let iconCamera =  UIImage(systemName: "camera.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
                lastMessageIconImageView.image =  .set("ic_chat_image")
                lastMessageLabel.text = "Foto"
            case .video:
                lastMessageIconImageView.isHidden = false
                let iconCamera = UIImage(systemName: "video.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
                lastMessageIconImageView.image = .set("ic_chat_video")
                lastMessageLabel.text = "Video"
            default:
                lastMessageIconImageView.isHidden = true
                lastMessageLabel.text = ""
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let selectBgView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        selectBgView.backgroundColor = .white
        self.selectedBackgroundView = selectBgView
    }
     
}
