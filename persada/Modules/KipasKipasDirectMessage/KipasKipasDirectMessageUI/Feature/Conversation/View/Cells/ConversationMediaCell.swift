//
//  ConversationMediaCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by MissYasiky on 2024/4/24.
//

import Foundation
import UIKit
import KipasKipasDirectMessage

protocol ConversationMediaCellDelegate: NSObject {
    func didLongPress(with cell: ConversationMediaCell, message: TXIMMessage, indexPath: IndexPath)
}

class ConversationMediaCell: UITableViewCell {
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
    
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let playImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setImage("ic_play_grey")
//        let image = UIImage(named: "ic_play_grey")?.withTintColor(UIColor(white: 1, alpha: 0.8))
//        imageView.image = image
        imageView.contentMode = .center
        return imageView
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
    
    let emojiView: ConversationCellEmojiView = {
        let view = ConversationCellEmojiView()
        return view
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
    
    public weak var delegate: ConversationMediaCellDelegate?
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
        self.bubbleView.addSubview(self.thumbnailImageView)
        self.thumbnailImageView.addSubview(self.playImageView)
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
            let imageSize = ConversationMediaCell.calculateImageViewSize(with: message)
            let bubbleWidth = 2 + imageSize.width + 2
            var bubbleHeight = 2 + imageSize.height + 2 + 14 + 2
            var orginY = 2.0
            if let quoteMsg = message.quoteMsg {
                if quoteMsg.type == .image || quoteMsg.type == .video {
                    self.quoteContainer.frame = CGRectMake(4, 4, bubbleWidth - 4 * 2, 54)
                    orginY = 4.0 + self.quoteContainer.frame.size.height + 2.0
                    
                    self.quoteLineView.frame = CGRectMake(0, 0, 4, self.quoteContainer.frame.size.height)
                    self.quoteImageView.frame = CGRectMake(self.quoteContainer.frame.size.width - 47, 0, 47, 54)
                    self.quoteUserNameLabel.frame = CGRectMake(13, 10, self.quoteContainer.frame.size.width - 13 - 47, 18)
                    self.quoteDescLabel.frame = CGRectMake(13, self.quoteUserNameLabel.frame.origin.y + 18, self.quoteUserNameLabel.frame.size.width, 16)
                    bubbleHeight += 4 + self.quoteContainer.frame.size.height
                } else if quoteMsg.type == .text {
                    self.quoteDescLabel.font = UIFont.systemFont(ofSize: 11)
                    self.quoteDescLabel.text = quoteMsg.text ?? ""
                    self.quoteDescLabel.numberOfLines = 3
                    let labelWidth = imageSize.width - 2 * 2 - 13 - 4
                    let size = self.quoteDescLabel.sizeThatFits(CGSizeMake(labelWidth, CGFLOAT_MAX))
                    
                    self.quoteContainer.frame = CGRectMake(4, 4, bubbleWidth - 4 * 2, 10 + 18 + size.height + 10)
                    orginY = 4.0 + self.quoteContainer.frame.size.height + 2.0
                    
                    self.quoteLineView.frame = CGRectMake(0, 0, 4, self.quoteContainer.frame.size.height)
                    self.quoteUserNameLabel.frame = CGRectMake(13, 10, self.quoteContainer.frame.size.width - 13 - 4, 18)
                    self.quoteDescLabel.frame = CGRectMake(13, self.quoteUserNameLabel.frame.origin.y + 18, size.width, size.height)
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
            
            self.thumbnailImageView.frame = CGRect(origin: CGPoint(x: 2, y: orginY), size: imageSize)
            self.playImageView.frame = CGRect(origin: CGPoint(x: (imageSize.width - 24) / 2.0, y: (imageSize.height - 28) / 2.0), size: CGSize(width: 24, height: 28))
            
            let detailOriginY = bubbleHeight - 2 - 14
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
            self.thumbnailImageView.frame = CGRectZero
            self.playImageView.frame = CGRectZero
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
        
        let isVideo = message.type == .video
        let imagePath = isVideo == true ? message.snapshotPath : message.imagePath
        let imageUrl = isVideo == true ? message.snapshotUrl : message.thumnailImageUrl
        var url: URL? = nil
        if let path = imagePath, FileManager.default.fileExists(atPath: path) {
            url = URL(fileURLWithPath: path)
        } else {
            url = URL(string: imageUrl ?? "")
        }
        playImageView.isHidden = !isVideo
        thumbnailImageView.sd_setImage(with: url, placeholderImage: UIImage.set("empty"))
        
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
    
    static func height(with message: TXIMMessage) -> CGFloat {
        let bubbleHeight = ConversationMediaCell.bubbleHeight(with: message)
        return 4 + bubbleHeight + (message.reactions.count > 0 ? 24 : 0) + 4
    }
    
    static func bubbleHeight(with message: TXIMMessage) -> CGFloat {
        let defaultImageSize = ConversationMediaCell.calculateImageViewSize(with: message)
        var height = 2 + defaultImageSize.height + 2 + 14 + 2
        if let quoteMsg = message.quoteMsg {
            if quoteMsg.type == .image || quoteMsg.type == .video {
                height += 4 + 54
            } else if quoteMsg.type == .text {
                let label: UILabel = UILabel()
                label.font = UIFont.systemFont(ofSize: 11)
                label.text = quoteMsg.text ?? ""
                label.numberOfLines = 3
                let labelWidth = defaultImageSize.width - 2 * 2 - 13 - 4
                let size = label.sizeThatFits(CGSizeMake(labelWidth, CGFLOAT_MAX))
                height += 4 + 10 + 18 + size.height + 10
            }
        }
        return height
    }
    
    static func calculateImageViewSize(with message: TXIMMessage) -> CGSize {
        let maxLength: CGFloat = 250.0;
        let minLength: CGFloat = 160.0
        let imageWidth: CGFloat = CGFloat(message.imageWidth)
        let imageHeight: CGFloat = CGFloat(message.imageHeight)
        if imageWidth == 0 || imageHeight == 0 {
            return CGSize(width: maxLength, height: maxLength)
        } else  {
            if imageWidth < imageHeight {
                let height = maxLength
                let caculateWidth = height * imageWidth / imageHeight
                let width = caculateWidth < minLength ? minLength : caculateWidth
                return CGSize(width: width, height: height)
            } else {
                let width = maxLength
                let caculateHeight = width * imageHeight / imageWidth
                let height = caculateHeight < minLength ? minLength : caculateHeight
                return CGSize(width: width, height: height)
            }
        }
    }
}
