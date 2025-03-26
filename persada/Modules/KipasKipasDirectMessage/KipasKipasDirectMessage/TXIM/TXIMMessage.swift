//
//  TXIMMessage.swift
//  KipasKipasDirectMessage
//
//  Created by MissYasiky on 2024/3/25.
//

import Foundation
import ImSDK_Plus

public enum TXIMMessageStatus {
    case unknow
    case sending
    case send_succ
    case send_fail
    case delete
    case revoke
    case local
}

public enum TXIMMessageType {
    case unknow
    case text
    case image
    case video
}

public class TXIMMessage {
    public var message: V2TIMMessage
    public var msgID: String
    
    public let timestamp: Date
    public let userID: String
    public let nickName: String
    public let faceURL: String
    public let isSelf: Bool
    public let type: TXIMMessageType
    public var isPaid: Bool = false
    public var price: Int?
    public var isPayer: Bool = false
    public var isRead: Bool = false {
        didSet {
            if isRead != oldValue {
                DispatchQueue.main.async {
                    self.statusChangeHandle?(self.status)
                }
            }
        }
    }
    
    public var quoteMsgID: String? = nil
    public var quoteMsg: TXIMMessage? = nil
    
    // only exist when type == .text
    public var text: String?
    
    // only exist when type == .image
    public var imagePath: String? // only exist when isSelf == true
    public var originImageUUID: String?
    public var originImageUrl: String?
    public var imageWidth: Int32 = 0
    public var imageHeight: Int32 = 0
    public var thumnailImageUUID: String?
    public var thumnailImageUrl: String?
    
    // only exist when type == .video
    public var videoPath: String? // only exist when isSelf == true
    public var snapshotPath: String? // only exist when isSelf == true
    public var videoUUID: String?
    public var videoUrl: String?
    public var snapshotUUID: String?
    public var snapshotUrl: String?
    
    public var emojiChangeHandle: (([(String, [String])]) -> Void)?
    public var statusChangeHandle: ((TXIMMessageStatus) -> Void)?
    public var cloudCustomDataChangedHandle: ((Bool, Int?, Bool) -> Void)?
    public var quoteMessageHandle: ((TXIMMessage) -> Void)?
    
    public var status: TXIMMessageStatus {
        get {
            if isRevoke {
                return .revoke
            } else {
                if message.status == .MSG_STATUS_SENDING {
                    return .sending
                } else if message.status == .MSG_STATUS_SEND_SUCC {
                    return .send_succ
                } else if message.status == .MSG_STATUS_SEND_FAIL {
                    return .send_fail
                } else if message.status == .MSG_STATUS_LOCAL_REVOKED {
                    return .revoke
                } else if message.status == .MSG_STATUS_HAS_DELETED {
                    return .delete
                } else if message.status == .MSG_STATUS_LOCAL_IMPORTED {
                    return .local
                } else {
                    return .unknow
                }
            }
        }
    }
    public var allowRevoke: Bool {
        return isSelf && timestamp.timeIntervalSinceNow > -2 * 60 && type == .text
    }
    public var isRevoke: Bool = false {
        didSet {
            revokeTimestamp = isRevoke ? Date() : nil
        }
    }
    public var revokeTimestamp: Date?
    public var reactions: [(String, [String])] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.emojiChangeHandle?(self.reactions)
            }
        }
    }
    public var myReaction: String? {
        get {
            for reaction in reactions {
                let emoji = reaction.0
                let userIds = reaction.1
                let userId = imManager.getLoginUser()
                if let userId, userIds.contains(userId) {
                    return emoji
                }
            }
            return nil
        }
    }
    
    private(set) lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
    }()
    
    init(message: V2TIMMessage) {
        self.message = message
        
        self.msgID = message.msgID ?? UUID().uuidString
        self.timestamp = message.timestamp
        self.userID = message.userID ?? ""
        self.nickName = message.nickName ?? ""
        self.faceURL = message.faceURL ?? ""
        self.isSelf = message.isSelf
        
        self.text = nil
        self.imagePath = nil
        self.originImageUUID = nil
        self.originImageUrl = nil
        self.thumnailImageUUID = nil
        self.thumnailImageUrl = nil
        self.videoPath = nil
        self.snapshotPath = nil
        self.videoUUID = nil
        self.videoUrl = nil
        self.snapshotUUID = nil
        self.snapshotUrl = nil
        
        if message.elemType == .ELEM_TYPE_TEXT {
            self.type = .text
            self.text = message.textElem.text
        } else if message.elemType == .ELEM_TYPE_IMAGE {
            self.type = .image
            self.imagePath = message.imageElem.path
            
            let images: [V2TIMImage] = message.imageElem.imageList
            for image in images {
                if image.type == .IMAGE_TYPE_ORIGIN {
                    self.originImageUUID = image.uuid
                    self.originImageUrl = image.url
                    self.imageWidth = image.width
                    self.imageHeight = image.height
                } else if image.type == .IMAGE_TYPE_THUMB {
                    self.thumnailImageUUID = image.uuid
                    self.thumnailImageUrl = image.url
                }
            }
        } else if message.elemType == .ELEM_TYPE_VIDEO {
            self.type = .video
            self.videoPath = message.videoElem.videoPath
            self.snapshotPath = message.videoElem.snapshotPath
            self.imageWidth = message.videoElem.snapshotWidth
            self.imageHeight = message.videoElem.snapshotHeight
            
            self.videoUUID = message.videoElem.videoUUID
            self.snapshotUUID = message.videoElem.snapshotUUID
        } else {
            self.type = .unknow
        }
        
        let result = updateCloudCustomData(message.cloudCustomData)
        self.isPaid = result.0
        self.price = result.1
        self.isPayer = result.2
        
        let dict: [String: Any]? = TXIMMessage.messageReplyFromCloudCustomData(message.cloudCustomData)
        self.quoteMsgID = dict?["messageID"] as? String
        
        if self.quoteMsgID != nil {
            imManager.findMessages([quoteMsgID!]) { [weak self] messages in
                guard let self else { return }
                if let msg = messages?.first {
                    self.quoteMsg = TXIMMessage.init(message: msg)
                    if let quoteMsg = self.quoteMsg {
                        self.quoteMessageHandle?(quoteMsg)
                    }
                }
            } fail: { code, desc in
                
            }
        }
        
        if self.type == .video {
            getVideoUrl()
            getSnapshotUrl()
        }
    }
    
    public func updateMessage(message: V2TIMMessage) {
        self.message = message
        self.msgID = message.msgID ?? ""
        
        if self.type == .video {
            getVideoUrl()
            getSnapshotUrl()
        }
        
        DispatchQueue.main.async {
            self.statusChangeHandle?(self.status)
        }
    }
    
    public func messageModify(_ msg: V2TIMMessage!) {
        guard let data = msg.cloudCustomData else {
            return
        }
        
        let result = updateCloudCustomData(data)
        self.isPaid = result.0
        self.price = result.1
        self.isPayer = result.2
        
        DispatchQueue.main.async {
            self.cloudCustomDataChangedHandle?(result.0, result.1, result.2)
        }
    }
    
    public func addEmoji(emoji: String) {
        var insertEmoji = true
        var processReactions: [(String, [String])] = []
        for reaction in reactions {
            if reaction.0 == emoji {
                insertEmoji = false
                var userIds: [String] = reaction.1
                if let loginUserId = imManager.getLoginUser() {
                    if userIds.contains(loginUserId) {
                        continue
                    } else {
                        userIds.append(loginUserId)
                    }
                }
                let processReaction = (reaction.0, userIds)
                processReactions.append(processReaction)
            } else {
                processReactions.append(reaction)
            }
        }
        if insertEmoji, let loginUserId = imManager.getLoginUser() {
            let processReaction: (String, [String]) = (emoji, [loginUserId])
            processReactions.append(processReaction)
        }
        reactions = processReactions
    }
    
    public func removeEmoji(emoji: String) {
        var processReactions: [(String, [String])] = []
        for reaction in reactions {
            var processReaction: (String, [String]) = ("", [])
            if reaction.0 == emoji {
                var userIds: [String] = []
                if let loginUserId = imManager.getLoginUser(), reaction.1.contains(loginUserId) {
                    for userId in reaction.1 {
                        if userId != loginUserId {
                            userIds.append(userId)
                        }
                    }
                }
                if userIds.count > 0 {
                    processReaction = (reaction.0, userIds)
                    processReactions.append(processReaction)
                }
            } else {
                processReaction = reaction
                processReactions.append(processReaction)
            }
        }
        reactions = processReactions
    }
    
    public func setEmojiChangeHandle(_ handle: @escaping (([(String, [String])]) -> Void)) {
        self.emojiChangeHandle = handle
    }
    
    public func setStatusChangeHandle(_ handle: @escaping ((TXIMMessageStatus) -> Void)) {
        self.statusChangeHandle = handle
    }
    
    public func setQuoteMessageHandle(_ handle: @escaping ((TXIMMessage) -> Void)) {
        self.quoteMessageHandle = handle
    }

    public func setCloudCustomDataChangedHandle(_ handle: @escaping ((Bool, Int?, Bool) -> Void)) {
        self.cloudCustomDataChangedHandle = handle
    }
    
    private func updateCloudCustomData(_ customData: Data?) -> (Bool, Int?, Bool) {
        guard let customData else {
            return (false, nil, false)
        }
        
        let backEndData = TXIMMessage.modifiedDataFromCloudCustomData(customData)
        let info = backEndData?["data"] as? [String: Any]
        let isPaid = info?["isPaid"] as? Bool ?? false
        let price = info?["chatPrice"] as? Int
        var isPayer = false
        if let payerId = info?["payerId"] as? String,
           let currentUserId = TXIMUserManger.shared.currentUserId {
            isPayer = payerId == currentUserId
        }
        return (isPaid, price, isPayer)
    }
    
    private func getVideoUrl() {
        guard let videoElem = self.message.videoElem else {
            return
        }
        videoElem.getVideoUrl { [weak self] url in
            if let url {
                self?.videoUrl = url
            }
        }
    }
    
    private func getSnapshotUrl() {
        guard let videoElem = self.message.videoElem else {
            return
        }
        videoElem.getSnapshotUrl { [weak self] url in
            if let url {
                self?.snapshotUrl = url
            }
        }
    }
    
    static public func messageReplyFromCloudCustomData(_ data: Data?) -> [String: Any]? {
        guard let data else {
            return nil
        }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let messageReply = dataDict["messageReply"] as? [String: Any] {
            return messageReply
        }
        
        return nil
    }
    
    static public func modifiedDataFromCloudCustomData(_ data: Data?) -> [String: Any]? {
        guard let data else {
            return nil
        }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let backEndData = dataDict["modifiedData"] as? [String: Any] {
            return backEndData
        }
        
        return nil
    }
    
    static public func serializeCustomMessageData(_ data: Data?) -> Bool {
        guard let data else {
            return false
        }
        
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            let type = dataDict["type"] as? String ?? ""
            if type == "paidChat" {
                return (dataDict["isPaid"] as? Bool ?? false)
            }
        }
        
        return false
    }
}
