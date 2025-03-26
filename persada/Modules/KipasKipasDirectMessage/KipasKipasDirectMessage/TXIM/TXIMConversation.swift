//
//  TXIMConversation.swift
//  KipasKipasDirectMessage
//
//  Created by MissYasiky on 2024/4/2.
//

import Foundation
import ImSDK_Plus

  
public class TXIMConversation {
    private var conv: V2TIMConversation
    
    public let convID: String
    public let userID: String
    public var nickName: String
    public var faceURL: String
    public var isVerified: Bool = false
    public var unreadCount: Int32
    public var lastMsgTimestamp: Date?
    public var lastMsgType: TXIMMessageType = .unknow
    public var isLastMsgRevoke: Bool = false
    public var isLastMsgSelf: Bool = false
    public var isPaid: Bool = false
    
    public var isUnread: Bool = false
    public var isPin: Bool = false
    public var isFold: Bool = false
    public var isLock: Bool = false
    
    // only exist when lastMsgType == .text
    public var text: String?
    
    init(conversation: V2TIMConversation) {
        self.conv = conversation
        
        self.convID = conversation.conversationID ?? ""
        self.userID = conversation.userID ?? ""
        if let name = conversation.showName, !name.isEmpty {
            self.nickName = name
        } else {
            self.nickName = self.userID
        }
        self.faceURL = conversation.faceUrl ?? ""
        self.unreadCount = conversation.unreadCount
        
        
        updateMark()
        updateLastMessage(message: conversation.lastMessage)
    }
    
    public func updateConversation(conversation: V2TIMConversation) {
        self.conv = conversation
        
        if let name = conversation.showName, !name.isEmpty {
            self.nickName = name
        } else {
            self.nickName = self.userID
        }
        self.faceURL = conversation.faceUrl ?? ""
        self.unreadCount = conversation.unreadCount
         
        updateMark()
        updateLastMessage(message: conversation.lastMessage)
    }
    
    private func updateMark(){
        self.isPin = conv.isPinned 
        print("markList --- \(String(describing: conv.markList))")
        let unreadType : TXV2TIMConversationMarkType = .CONVERSATION_MARK_TYPE_UNREAD
        self.isUnread = conv.markList.contains(unreadType.rawValue as NSNumber)
        
        let foldType : TXV2TIMConversationMarkType = .CONVERSATION_MARK_TYPE_FOLD
        self.isFold = conv.markList.contains(foldType.rawValue as NSNumber)
        
        let lockType : TXV2TIMConversationMarkType = .CONVERSATION_MARK_TYPE_LOCK
        self.isLock = conv.markList.contains(lockType.rawValue as NSNumber)
    }
    
    private func updateLastMessage(message: V2TIMMessage?) {
          
        guard let lastMsg = message else {
            self.lastMsgType = .unknow
            self.isPaid = false
            return
        }
        
        self.lastMsgTimestamp = lastMsg.timestamp
        if lastMsg.elemType == .ELEM_TYPE_TEXT {
            self.lastMsgType = .text
            self.text = lastMsg.textElem.text
        } else if lastMsg.elemType == .ELEM_TYPE_IMAGE {
            self.lastMsgType = .image
        } else if lastMsg.elemType == .ELEM_TYPE_VIDEO {
            self.lastMsgType = .video
        } else {
            self.lastMsgType = .unknow
        }
        self.isLastMsgRevoke = message?.status == .MSG_STATUS_LOCAL_REVOKED
        self.isLastMsgSelf = message?.isSelf ?? false
        
        if lastMsg.elemType == .ELEM_TYPE_CUSTOM {
            self.isPaid = TXIMMessage.serializeCustomMessageData(lastMsg.customElem.data)
        } else {
            let data = TXIMMessage.modifiedDataFromCloudCustomData(lastMsg.cloudCustomData)
            let info = data?["data"] as? [String: Any]
            self.isPaid = info?["isPaid"] as? Bool ?? false
        }
    }
}
