//
//  ConversationMenuWindow.swift
//  KipasKipasDirectMessageUI
//
//  Created by MissYasiky on 2024/4/15.
//

import Foundation
import UIKit
import KipasKipasDirectMessage

protocol ConversationMenuWindowDelegate: NSObject {
    func menuWindow(_ menuWindow: ConversationMenuWindow, didSelectAt type: MenuItemType, message: TXIMMessage?)
    func menuWindow(_ menuWindow: ConversationMenuWindow, didSelectEmoji emoji: String?, message: TXIMMessage?)
}

class ConversationMenuWindow: UIWindow {
    static let instance = ConversationMenuWindow.init()
    static let backgroudHexColor: String = "#2B2B2B"
    static let animationDuration: CGFloat = 0.2
    
    weak private var delegate: ConversationMenuWindowDelegate?
    private var backgroudView: UIView!
    private var menuView: ConversationMenuView?
    private var emojiView: MessageReactionSelectionView?
    private var messageView: UIView?
    private var message: TXIMMessage?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        self.windowLevel = .normal + 1
        self.isHidden = true
        
        self.backgroudView = UIView()
        self.backgroudView.backgroundColor = UIColor(hexString: ConversationMenuWindow.backgroudHexColor, alpha:0)
        self.backgroudView.frame = self.bounds
        self.addSubview(self.backgroudView)
        
        self.backgroudView.onTap {
            ConversationMenuWindow.dismiss()
        }
    }
    
    static func showCell(at point: CGPoint, message: TXIMMessage, priceType: TXIMChatPriceType, delegate: ConversationMenuWindowDelegate) {
        let window = ConversationMenuWindow.instance
        if !window.isHidden {
            return
        }
        
        window.isHidden = false
        window.delegate = delegate
        window.message = message
        
        let emojiView = ConversationMenuWindow.setupEmojiSelectionView(message)
        emojiView.delegate = window
        window.emojiView = emojiView
        window.addSubview(emojiView)
        
        let messageView = ConversationMenuWindow.setupMessageBubbleView(message, priceType: priceType)
        window.messageView = messageView
        window.addSubview(messageView)
        
        let menu = ConversationMenuWindow.setupMenuView(message)
        menu.delegate = window
        window.menuView = menu
        window.addSubview(menu)
        
        ConversationMenuWindow.showAnimation(from: point, isSelf: message.isSelf)
    }
    
    static func showAnimation(from startPoint: CGPoint, isSelf: Bool) {
        let window = ConversationMenuWindow.instance
        guard let messageView = window.messageView, let menuView = window.menuView, let emojiView = window.emojiView else {
            return
        }
        
        // 动画结束位置计算
        let width = window.bounds.size.width
        let height = window.bounds.size.height
        let msgSize = messageView.frame.size
        var msgEndPoint = startPoint
        let padding = isSelf ? width - msgEndPoint.x - msgSize.width : msgEndPoint.x
        var menuEndPoint = CGPoint(x: padding, y: msgEndPoint.y + msgSize.height + 10)
        if isSelf {
            menuEndPoint.x = width - padding - menuView.width
        }
        let safeTop = window.safeAreaInsets.top + 15
        let safeBottom = window.safeAreaInsets.bottom + 15
        if menuEndPoint.y + menuView.height + safeBottom > height {
            menuEndPoint.y = height - safeBottom - menuView.height
            msgEndPoint.y = menuEndPoint.y - 10 - msgSize.height
        }
        if msgEndPoint.y < safeTop + emojiView.height + 10 {
            msgEndPoint.y = safeTop + emojiView.height + 10
            menuEndPoint.y = msgEndPoint.y + msgSize.height + 10
            if menuEndPoint.y + menuView.height + safeBottom > height {
                menuEndPoint.y = height - safeBottom - menuView.height
            }
        }
        var emojiEndPoint = CGPoint(x: padding, y: msgEndPoint.y - 10 - emojiView.height)
        if isSelf {
            emojiEndPoint.x = width - padding - emojiView.width
        }
        
        // 起始位置设置
        messageView.frame = CGRect(origin: startPoint, size: msgSize)
        if isSelf {
            menuView.frame = CGRect(x: menuEndPoint.x, y: width - 10, width: 0, height: 0)
        } else {
            menuView.frame = CGRect(origin: menuEndPoint, size: CGSizeZero)
        }
        emojiView.frame = CGRect(origin: emojiEndPoint, size: CGSizeZero)
        
        UIView.animate(withDuration: animationDuration) {
            // 底部颜色变化
            window.backgroudView.backgroundColor = UIColor(hexString: ConversationMenuWindow.backgroudHexColor, alpha:0.5)
            
            // 结束位置设置
            messageView.frame = CGRect(origin: msgEndPoint, size: msgSize)
            menuView.frame = CGRect(origin: menuEndPoint, size: CGSize(width: menuView.width, height: menuView.height))
            emojiView.frame = CGRect(origin: emojiEndPoint, size: CGSize(width: emojiView.width, height: emojiView.height))
        }
    }
    
    static func dismiss() {
        let window = ConversationMenuWindow.instance
        if window.isHidden {
            return
        }
        
        let menuView: ConversationMenuView? = window.menuView
//        let menuPoint = menuView?.frame.origin ?? CGPointZero
        let emojiView: MessageReactionSelectionView? = window.emojiView
//        let emojiPoint = emojiView?.frame.origin ?? CGPointZero
        let messageView: UIView? = window.messageView
        
        UIView.animate(withDuration: animationDuration) {
            // 底部颜色变化
            window.backgroudView.backgroundColor = UIColor(hexString: ConversationMenuWindow.backgroudHexColor, alpha:0)
            menuView?.isHidden = true
            emojiView?.isHidden = true
            messageView?.isHidden = true
            
//            // 结束位置设置
//            if window.message?.isSelf ?? false {
//                menuView?.frame = CGRect(origin: CGPoint(x: menuPoint.x, y: menuPoint.y + (menuView?.width ?? 0)), size: CGSizeZero)
//            } else {
//                menuView?.frame = CGRect(origin: menuPoint, size: CGSizeZero)
//            }
        } completion: { _ in
            window.reset()
        }
    }
    
    static func setupMenuView(_ message: TXIMMessage) -> ConversationMenuView {
        let menu = ConversationMenuView()
        menu.allowCopy = message.type == .text
        menu.allowRevoke = message.allowRevoke
        menu.allowReply = message.status == .send_succ
        menu.isPin = false
        return menu
    }
    
    static func setupEmojiSelectionView(_ message: TXIMMessage) -> MessageReactionSelectionView {
        let emojiView = MessageReactionSelectionView()
        emojiView.selectedEmoji = message.myReaction
        return emojiView
    }
    
    static func setupMessageBubbleView(_ message: TXIMMessage, priceType: TXIMChatPriceType) -> UIView {
        if message.type == .text {
            let cell: ConversationTextCell  = ConversationTextCell(style: .default, reuseIdentifier: nil)
            cell.updateMessage(message, enableSelect:false, type: priceType)
            return cell.bubbleView
        } else if message.type == .image || message.type == .video {
            let cell: ConversationMediaCell  = ConversationMediaCell(style: .default, reuseIdentifier: nil)
            cell.updateMessage(message, enableSelect:false, type: priceType)
            return cell.bubbleView
        } else {
            return UIView()
        }
    }
    
    func reset() {
        self.isHidden = true
        
        messageView?.removeFromSuperview()
        messageView = nil
        
        menuView?.removeFromSuperview()
        menuView?.delegate = nil
        menuView = nil
        
        emojiView?.removeFromSuperview()
        emojiView?.delegate = nil
        emojiView = nil
        
        message = nil
        delegate = nil
    }
}

extension ConversationMenuWindow: ConversationMenuViewDelegate {
    func menuView(_ menuView: ConversationMenuView, didSelectAt type: MenuItemType) {
        self.delegate?.menuWindow(self, didSelectAt: type, message: message)
        ConversationMenuWindow.dismiss()
    }
}

extension ConversationMenuWindow: MessageReactionSelectionViewDelegate {
    func reactionSelectionView(_ reactionSelectionView: MessageReactionSelectionView, didSelect emoji: String) {
        self.delegate?.menuWindow(self, didSelectEmoji: emoji, message: message)
        ConversationMenuWindow.dismiss()
    }
}
