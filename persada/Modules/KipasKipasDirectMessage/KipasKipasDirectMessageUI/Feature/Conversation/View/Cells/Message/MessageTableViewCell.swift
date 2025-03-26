//
//  MessageTableViewCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 16/07/23.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

class MessageTableViewCell: UITableViewCell, Accessible {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var messageComponentStackView: UIStackView!
    
    @IBOutlet weak var messageLabel: ActiveLabel!
    @IBOutlet weak var increaseDiamondContainerStackView: UIStackView!
    @IBOutlet weak var diamondPriceLabel: UILabel!
    @IBOutlet weak var decreaseCoinContainerStackView: UIStackView!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var messageSendingdateLabel: UILabel!
    @IBOutlet weak var messageStatusIconImageView: UIImageView!
    
    @IBOutlet weak var selectedConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        generateAccessibilityIdentifiers()
        
        messageLabel.enabledTypes = [.mention, .hashtag, .url]
        
        messageLabel.configureLinkAttribute = .some({ (ActiveType, _: [NSAttributedString.Key : Any], Bool) -> ([NSAttributedString.Key : Any]) in
            if ActiveType == .mention {
                return [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 16), NSAttributedString.Key.foregroundColor: UIColor.secondary]
            } else if ActiveType == .hashtag {
                return [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 16), NSAttributedString.Key.foregroundColor: UIColor.secondary]
            } else if ActiveType == .url {
                return [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 16), NSAttributedString.Key.foregroundColor: UIColor.secondary]
            }
            return [NSAttributedString.Key: Any]()
        })
    }
    
    func configure(with message: TXIMMessage, selecting: Bool) {
        self.selectedConstraint?.constant = selecting ? 17 : -27
        self.selectedImageView.isHidden = !selecting
        
        updateMessageStatus(message)
        defaultMessageLayout(isSender: message.isSelf)
        
        var text = message.text ?? ""
        if let reaction = message.reactions.first {
            text += "【" + reaction.0 + "】"
        }
        if let quoteMsgID = message.quoteMsgID {
            if let quoteMsg = message.quoteMsg {
                var content = ""
                if quoteMsg.type == .text {
                    content = quoteMsg.text ?? ""
                } else if quoteMsg.type == .image {
                    content = "<image>"
                } else {
                    content = "<video>"
                }
                text = "[reply:" + content + "]" + text
            } else {
                text = "[reply:]" + text
            }
        }
        if message.status == .revoke {
            text = "【this message was revoke】"
        }
        messageLabel.text = text
        messageSendingdateLabel.text = message.timestamp.sbu_toString(format: .HHmm)
    }
    
    func updateDiamondIncreaseOrCoinDecrease(type: TXIMChatPriceType, price: Int?) {
        if let price, price > 0 {
            switch type {
            case .increase_diamond:
                increaseDiamondContainerStackView.isHidden = false
                decreaseCoinContainerStackView.isHidden = true
            case .decrease_coin:
                increaseDiamondContainerStackView.isHidden = true
                decreaseCoinContainerStackView.isHidden = false
            default:
                increaseDiamondContainerStackView.isHidden = true
                decreaseCoinContainerStackView.isHidden = true
            }
            
            diamondPriceLabel.text = "+\(price)"
            coinPriceLabel.text = "-\(price)"
        } else {
            increaseDiamondContainerStackView.isHidden = true
            decreaseCoinContainerStackView.isHidden = true
        }
    }
    
    func updateMessageStatus(_ message: TXIMMessage) {
        switch message.status {
        case .sending:
            messageStatusIconImageView.image = UIImage.set("ic_clock_gray")
        case .send_succ:
            messageStatusIconImageView.image = UIImage.set("ic_check_double_grey")
        case .send_fail:
            messageStatusIconImageView.image = UIImage.set("ic_arrow_rotate_right_red")
        default:
            messageStatusIconImageView.image = UIImage.set("ic_clock_gray")
        }
        if message.isRead {
            messageStatusIconImageView.image = UIImage.set("ic_check_double_blue")
        }
    }
    
    func defaultMessageLayout(isSender: Bool) {
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = .init(top: 0, left: isSender ? 90 : 0, bottom: 0, right: isSender ? 0 : 90)
        containerStackView.alignment = isSender ? .trailing : .leading
        messageComponentStackView.alignment = containerStackView.alignment
        messageComponentStackView.backgroundColor = UIColor(hexString: isSender ? "#E1FED3" : "#F9F9F9")
        messageStatusIconImageView.isHidden = !isSender
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.selectedImageView.setImage("conv_message_selected")
        } else {
            self.selectedImageView.image = nil
        }
    }
}
