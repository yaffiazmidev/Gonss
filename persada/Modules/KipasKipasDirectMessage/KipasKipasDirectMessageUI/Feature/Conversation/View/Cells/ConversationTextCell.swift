//
//  ConversationTextCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by MissYasiky on 2024/4/23.
//

import Foundation
import UIKit
import KipasKipasDirectMessage

protocol ConversationTextCellDelegate: NSObject {
    func didLongPress(with cell: ConversationTextCell, message: TXIMMessage, indexPath: IndexPath)
}

class ConversationTextCell: UITableViewCell {
    let selectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set("ic_clock_gray")
        imageView.layer.cornerRadius = 10.0
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(hexString: "#C0B8B2").cgColor
        imageView.layer.borderWidth = 1.0
        return imageView
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hexString: "#777777", alpha: 0.8)
        label.textAlignment = .right
        return label
    }()
    
    let stateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set("ic_clock_gray")
        imageView.contentMode = .center
        return imageView
    }()
    
    let paidLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(hexString: "#4A4A4A", alpha: 0.8)
        return label
    }()
    
    let quoteContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#000000", alpha: 0.05)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 6.0
        return view
    }()
    
    let quoteLineView: UIView = {
        let view = UIView()
        return view
    }()
    
    let quoteUserNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let quoteDescLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let quoteImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let emojiView: ConversationCellEmojiView = {
        let view = ConversationCellEmojiView()
        return view
    }()
    
    public weak var delegate: ConversationTextCellDelegate?
    public var indexPath: IndexPath?
    private var message: TXIMMessage?
    private var enableSelect: Bool = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(self.selectImageView)
        self.contentView.addSubview(self.bubbleView)
        self.contentView.addSubview(self.emojiView)
        self.bubbleView.addSubview(self.messageLabel)
        self.bubbleView.addSubview(self.dateLabel)
        self.bubbleView.addSubview(self.stateImageView)
        self.bubbleView.addSubview(self.paidLabel)
        
        self.bubbleView.addSubview(self.quoteContainer)
        self.quoteContainer.addSubview(self.quoteLineView)
        self.quoteContainer.addSubview(self.quoteUserNameLabel)
        self.quoteContainer.addSubview(self.quoteDescLabel)
        self.quoteContainer.addSubview(self.quoteImageView)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction))
        self.bubbleView.addGestureRecognizer(gesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.message = nil
        self.enableSelect = false
        self.selectImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let boundWidth = self.contentView.bounds.size.width
        
        if let message = self.message {
            let bubbleWidth = self.bubbleWidthWithMessage(message, enableSelect: enableSelect)
            let size = self.messageLabel.sizeThatFits(CGSizeMake(bubbleWidth - 8 * 2, CGFLOAT_MAX))
            var bubbleHeight = 8 + size.height + 8 + 14 + 8
            var orginY = 8.0
            
            if let quoteMsg = message.quoteMsg {
                if quoteMsg.type == .image || quoteMsg.type == .video {
                    self.quoteContainer.frame = CGRectMake(4, 4, bubbleWidth - 4 * 2, 54)
                    orginY = 4.0 + self.quoteContainer.frame.size.height + 8.0
                    
                    self.quoteLineView.frame = CGRectMake(0, 0, 4, self.quoteContainer.frame.size.height)
                    self.quoteImageView.frame = CGRectMake(self.quoteContainer.frame.size.width - 47, 0, 47, 54)
                    self.quoteUserNameLabel.frame = CGRectMake(13, 10, self.quoteContainer.frame.size.width - 13 - 47, 18)
                    self.quoteDescLabel.frame = CGRectMake(13, self.quoteUserNameLabel.frame.origin.y + 18, self.quoteUserNameLabel.frame.size.width, 16)
                    bubbleHeight += 4 + self.quoteContainer.frame.size.height
                } else if quoteMsg.type == .text {
                    self.quoteDescLabel.font = UIFont.systemFont(ofSize: 11)
                    self.quoteDescLabel.text = quoteMsg.text ?? ""
                    self.quoteDescLabel.numberOfLines = 3
                    let labelWidth = bubbleWidth - 18 - 8
                    let size = self.quoteDescLabel.sizeThatFits(CGSizeMake(labelWidth, CGFLOAT_MAX))
                    
                    self.quoteContainer.frame = CGRectMake(4, 4, bubbleWidth - 4 * 2, 10 + 18 + size.height + 10)
                    orginY = 4.0 + self.quoteContainer.frame.size.height + 8.0
                    
                    self.quoteLineView.frame = CGRectMake(0, 0, 4, self.quoteContainer.frame.size.height)
                    self.quoteUserNameLabel.frame = CGRectMake(14, 10, self.quoteContainer.frame.size.width - 14 - 4, 18)
                    self.quoteDescLabel.frame = CGRectMake(14, self.quoteUserNameLabel.frame.origin.y + 18, size.width, size.height)
                    bubbleHeight += 4 + self.quoteContainer.frame.size.height
                }
            }
            
            var bubbleOriginX = 0.0
            if message.isSelf {
                bubbleOriginX = boundWidth - 22.0 - bubbleWidth
            } else {
                bubbleOriginX = self.enableSelect ? 52.0 : 22.0
            }
            self.bubbleView.frame = CGRect(origin: CGPoint(x: bubbleOriginX, y: 4), size: CGSize(width: bubbleWidth, height: bubbleHeight))
            
            self.messageLabel.frame = CGRect(origin: CGPoint(x: 8, y: orginY), size: CGSize(width: size.width, height: size.height))
            
            let detailOriginY = bubbleHeight - 8 - 14
            let stateImageViewWith = self.stateImageView.isHidden ? 0 : 20.0
            self.stateImageView.frame = CGRect(origin: CGPoint(x: bubbleWidth - 8 - stateImageViewWith, y: detailOriginY), size: CGSizeMake(stateImageViewWith, 14))
            
            let dateLabelWidth = 40.0
            let dateLabelOriginX = self.stateImageView.frame.origin.x - dateLabelWidth
            self.dateLabel.frame = CGRect(origin: CGPoint(x: dateLabelOriginX, y: detailOriginY), size: CGSizeMake(dateLabelWidth, 14))
            self.selectImageView.frame = CGRect(origin: CGPoint(x: 17, y: self.bubbleView.frame.origin.y + self.bubbleView.frame.size.height / 2.0 - 10), size: CGSizeMake(20, 20))
            if !self.paidLabel.isHidden {
                self.paidLabel.frame = CGRect(origin: CGPoint(x: 8, y: detailOriginY), size: CGSize(width: 30, height: 14))
            }
            
            let emojiViewSize = self.emojiView.caculateSize
            let emojiViewOriginX = message.isSelf ? boundWidth - emojiViewSize.width - 32 : 32
            let emojiViewOriginY = bubbleView.frame.origin.y + bubbleView.frame.size.height - 4
            self.emojiView.frame = CGRect(origin: CGPoint(x: emojiViewOriginX, y: emojiViewOriginY), size: emojiViewSize)
        } else {
            self.bubbleView.frame = CGRectZero
            self.messageLabel.frame = CGRectZero
            self.stateImageView.frame = CGRectZero
            self.dateLabel.frame = CGRectZero
            self.paidLabel.frame = CGRectZero
            self.emojiView.frame = CGRectZero
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.selectImageView.setImage("conv_message_selected")
        } else {
            self.selectImageView.image = nil
        }
    }
    
    @objc func longGestureAction() {
        guard let message, let indexPath else {
            return
        }
        delegate?.didLongPress(with: self, message: message, indexPath: indexPath)
    }
    
    func autoUpdateMessage(_ message: TXIMMessage, indexPath: IndexPath, enableSelect: Bool, type: TXIMChatPriceType) {
        guard let originIndexPath = self.indexPath, indexPath.row == originIndexPath.row else {
            return
        }
        updateMessage(message, indexPath: indexPath, enableSelect: enableSelect, type: type)
    }
    
    func updateMessage(_ message: TXIMMessage, indexPath: IndexPath? = nil, enableSelect: Bool, type: TXIMChatPriceType) {
        self.message = message
        self.indexPath = indexPath
        self.enableSelect = enableSelect
        
        selectImageView.isHidden = !enableSelect
        bubbleView.backgroundColor = UIColor(hexString: message.isSelf ? "#E1FED3" : "#F9F9F9")
        messageLabel.text = message.text ?? ""
        updateMessageStatus(message)
        dateLabel.text = message.timestamp.sbu_toString(format: .HHmm)
        emojiView.updateEmoji(message.reactions)
        
        if let price = message.price, price > 0, type != .none {
            self.paidLabel.isHidden = false
            
            let muString: NSMutableAttributedString = NSMutableAttributedString()
            let text = type == .decrease_coin ? "-\(price)" : "+\(price)"
            let attributeDict: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor(hexString: "#4A4A4A", alpha: 0.8)
            ]
            let string = NSAttributedString(string: text, attributes: attributeDict)
            muString.append(string)
            
            let attach: NSTextAttachment = NSTextAttachment()
            attach.bounds = CGRectMake(0, -2, 12, 12);
            attach.image = UIImage.set(type == .decrease_coin ? "ic_coin_gold" : "ic_diamond_blue")
            muString.append(NSAttributedString(attachment: attach))
            paidLabel.attributedText = muString
        } else {
            self.paidLabel.isHidden = true
            self.paidLabel.text = ""
        }
        
        if let quoteMsg = message.quoteMsg {
            if quoteMsg.type == .image || quoteMsg.type == .video || quoteMsg.type == .text {
                self.quoteContainer.isHidden = false
                let hexColor = quoteMsg.isSelf ? "#19A901" : "#D9006A"
                self.quoteLineView.backgroundColor = UIColor(hexString: hexColor)
                self.quoteUserNameLabel.textColor = UIColor(hexString: hexColor)
                self.quoteUserNameLabel.text = quoteMsg.isSelf ? "You" : quoteMsg.nickName
                
                if quoteMsg.type != .text {
                    let isVideo = quoteMsg.type == .video
                    let imagePath = isVideo == true ? quoteMsg.snapshotPath : quoteMsg.imagePath
                    let imageUrl = isVideo == true ? quoteMsg.snapshotUrl : quoteMsg.thumnailImageUrl
                    var url: URL? = nil
                    if let path = imagePath, FileManager.default.fileExists(atPath: path) {
                        url = URL(fileURLWithPath: path)
                    } else {
                        url = URL(string: imageUrl ?? "")
                    }
                    self.quoteImageView.sd_setImage(with: url, placeholderImage: UIImage.set("empty"))
                    self.quoteImageView.isHidden = false
                    
                    let muString: NSMutableAttributedString = NSMutableAttributedString()
                    
                    let attach: NSTextAttachment = NSTextAttachment()
                    attach.bounds = isVideo ? CGRectMake(0, -2, 14.5, 10) : CGRectMake(0, -2, 12, 12)
                    attach.image = UIImage.set(isVideo ? "conv_reply_msg_video_icon" : "conv_reply_msg_image_icon")
                    muString.append(NSAttributedString(attachment: attach))
                    
                    let text = isVideo ? " Video" : " Foto"
                    let attributeDict: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 11),
                        .foregroundColor: UIColor(hexString: "#48494F")
                    ]
                    let string = NSAttributedString(string: text, attributes: attributeDict)
                    muString.append(string)
                    self.quoteDescLabel.attributedText = muString
                } else {
                    self.quoteDescLabel.text = quoteMsg.text ?? ""
                    self.quoteDescLabel.textColor = UIColor(hexString: "#48494F")
                    self.quoteDescLabel.font = UIFont.systemFont(ofSize: 11)
                    self.quoteImageView.isHidden = true
                }
            } else {
                self.quoteContainer.isHidden = true
            }
        } else {
            self.quoteContainer.isHidden = true
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func updateMessageStatus(_ message: TXIMMessage) {
        stateImageView.isHidden = !message.isSelf
        if message.isRead {
            stateImageView.image = UIImage.set("ic_check_double_blue")
        } else {
            if message.status == .sending {
                stateImageView.image = UIImage.set("ic_clock_gray")
            } else if message.status == .send_succ {
                stateImageView.image = UIImage.set("ic_check_double_grey")
            } else if message.status == .send_fail {
                stateImageView.image = UIImage.set("ic_arrow_rotate_right_red")
            } else {
                stateImageView.image = nil
            }
        }
    }
    
    func bubbleWidthWithMessage(_ message: TXIMMessage, enableSelect: Bool) -> CGFloat {
        var maxBubbleWidth = UIScreen.main.bounds.size.width - 66.0 - 22.0
        if !message.isSelf && enableSelect {
            maxBubbleWidth -= 30.0
        }
        
        let messageLabelSize = self.messageLabel.sizeThatFits(CGSizeMake(maxBubbleWidth - 8 * 2, CGFLOAT_MAX))
        var quoteBubbleWidth: CGFloat = 0.0
        if let quoteMsg = message.quoteMsg {
            if quoteMsg.type == .image || quoteMsg.type == .video {
                quoteBubbleWidth = 160
            } else if quoteMsg.type == .text {
                let size = self.quoteDescLabel.sizeThatFits(CGSizeMake(maxBubbleWidth - 18 - 8, CGFLOAT_MAX))
                let caculateSize = size.width + 18 + 8
                quoteBubbleWidth = caculateSize > 160 ? caculateSize : 160
            }
        }
        let caculateBubbleWidth = messageLabelSize.width + 8 * 2
        let minBubbleWidth = 8.0 + 35.0 + (message.isSelf ? 20.0 : 0) + 8.0 + (self.paidLabel.isHidden ? 0 : 25)
        var bubbleWidth = caculateBubbleWidth > minBubbleWidth ? caculateBubbleWidth : minBubbleWidth
        if bubbleWidth > quoteBubbleWidth {
            return bubbleWidth
        } else {
            return quoteBubbleWidth
        }
    }
    
    static func heightWithMessage(_ message: TXIMMessage, enableSelect: Bool) -> CGFloat {
        let bubbleHeight = ConversationTextCell.bubbleHeightWithMessage(message, enableSelect: enableSelect)
        return 4 + bubbleHeight + (message.reactions.count > 0 ? 24 : 0) + 4
    }
    
    static func bubbleHeightWithMessage(_ message: TXIMMessage, enableSelect: Bool) -> CGFloat {
        var maxBubbleWidth = UIScreen.main.bounds.size.width - 66.0 - 22.0
        if !message.isSelf && enableSelect {
            maxBubbleWidth -= 30.0
        }
        
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = message.text ?? ""
        label.numberOfLines = 0
        let size = label.sizeThatFits(CGSizeMake(maxBubbleWidth - 8 * 2, CGFLOAT_MAX))
        var bubbleHeight = 8 + size.height + 8 + 14 + 8
        
        if let quoteMsg = message.quoteMsg {
            if quoteMsg.type == .text {
                let label: UILabel = UILabel()
                label.font = UIFont.systemFont(ofSize: 11)
                label.text = quoteMsg.text ?? ""
                label.numberOfLines = 3
                let size = label.sizeThatFits(CGSizeMake(maxBubbleWidth - 18 - 8, CGFLOAT_MAX))
                bubbleHeight += 4 + 8 + 18 + size.height + 8
            } else if quoteMsg.type == .image || quoteMsg.type == .video {
                bubbleHeight += 4 + 54
            }
        }
        
        return bubbleHeight
    }
}
