//
//  TXIMMessageManager.swift
//  KipasKipasDirectMessage
//
//  Created by MissYasiky on 2024/3/18.
//

import Foundation
import ImSDK_Plus
import AVFoundation
import UIKit

let TXIMMessagePageSize: Int32 = 20
let TXIMMessageErrorDomain = "com.kipaskipas.TXIMMessageManager"

public protocol TXIMMessageManagerDelegate: NSObject {
    func didMessageClear(with messageManager: TXIMMessageManager)
    func messageManager(_ messageManager: TXIMMessageManager, didMessageUpdate messages: [TXIMMessage])
    func messageManager(_ messageManager: TXIMMessageManager, didMessageDelete messages: [TXIMMessage])
    func messageManager(_ messageManager: TXIMMessageManager, didMessageReceive message: TXIMMessage)
    func messageManager(_ messageManager: TXIMMessageManager, didMessageForward messages: [TXIMMessage])
    func didMessageRevoke(with messageManager: TXIMMessageManager)
    func messageManager(_ messageManager: TXIMMessageManager, didLoadMessageError error: Error)
    func messageManager(_ messageManager: TXIMMessageManager, didMessageSent message: TXIMMessage)
    func messageManager(_ messageManager: TXIMMessageManager, didMessageSentSuccess message: TXIMMessage)
    func messageManager(_ messageManager: TXIMMessageManager, didMessageSentFailure message: TXIMMessage, error: NSError)
    func messageManager(_ messageManager: TXIMMessageManager, didPaidChatStatusChanged isPaid: Bool)
    func messageManager(_ messageManager: TXIMMessageManager, didReceiveCloudCustomData balance: PaidSessionBalance)
}

public final class TXIMMessageManager: NSObject {
    public var messageList: [TXIMMessage] {
        get {
            return messages
        }
    }
    public let userId: String
    public var isPaidChat: Bool = false
    public var balance: PaidSessionBalance?
    weak public var delegate: TXIMMessageManagerDelegate?
    
    private var cleanTimestamp: UInt64 = 0
    private let pushInfo = V2TIMOfflinePushInfo()
    private var messages: [TXIMMessage] = []
    private var lastMessage: V2TIMMessage?
    private var loadAllMsg: Bool = false
    private var isLoading: Bool = false
    private let pageSize: Int32 = TXIMMessagePageSize
    private let serialQueue = DispatchQueue(label: TXIMMessageErrorDomain)
    private(set) lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
    }()
    
    public init(userId: String) {
        self.userId = userId
        super.init()
    }
    
    deinit {
        print("【DM】deinit TXIMMessageManager")
    }
    
    public func addTXIMListener() {
        imManager.addAdvancedMsgListener(listener: self)
    }
    
    private func isMessageSupport(_ message: V2TIMMessage!) -> Bool {
        if message.elemType == .ELEM_TYPE_TEXT ||
            message.elemType == .ELEM_TYPE_IMAGE ||
            message.elemType == .ELEM_TYPE_VIDEO {
            return true
        } else {
            return false
        }
    }
}
 
// MARK: Message Load
extension TXIMMessageManager {
    public func loadInitMessages() {
        loadMessages(count: pageSize)
    }
    
    public func loadPreviousMessages() {
        loadMessages(count: pageSize)
    }
    
    private func loadMessages(count: Int32) {
        guard isLoading == false && loadAllMsg == false else {
            return
        }
        isLoading = true
        imManager.getC2CHistoryMessageList(userId, count: count, lastMsg: lastMessage) { [weak self] messages in
            guard let self else { return }
            self.isLoading = false
            if let messages {
                self.lastMessage = messages.last
                self.loadAllMsg = messages.count > 0 ? false : true
                
                self.insertOldMessages(messages: messages) { [weak self] sum, msgList in
                    guard let self else { return }
                    self.getMessageReactions(msgList)
                    self.getMessageReadReceipts(msgList)
                    if sum < count && !self.loadAllMsg {
                        self.loadMessages(count: count - sum)
                    } else {
                        self.notifyMessagesUpdate()
                    }
                }
            } else {
                self.loadAllMsg = true
            }
        } fail: { [weak self] code, desc in
            guard let self else { return }
            self.isLoading = false
            let errorDesc = desc ?? ""
            let error = NSError(domain: TXIMMessageErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: errorDesc])
            self.delegate?.messageManager(self, didLoadMessageError: error)
        }
    }
}

// MARK: Message Excute
extension TXIMMessageManager {
    @discardableResult public func deleteMessages(_ messages: [TXIMMessage], completion: @escaping (Bool, NSError?) -> Void) -> Bool {
        guard messages.count <= 50 else {
            return false
        }
        let processMessages: [V2TIMMessage] = messages.map { $0.message }
        imManager.delete(processMessages) {[weak self] in
            if let self {
                self.removeMessages(messages: messages)
            }
            completion(true, nil)
        } fail: { code, desc in
            let errorDesc = desc ?? ""
            let error = NSError(domain: TXIMMessageErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: errorDesc])
            completion(false, error)
        }
        return true
    }
    
    @discardableResult public func revokeMessage(_ message: TXIMMessage, completion: @escaping (Bool, NSError?) -> Void) -> Bool {
        guard message.timestamp.timeIntervalSinceNow > -2 * 60 else {
            return false
        }
        imManager.revokeMessage(message.message) {
            message.isRevoke = true
            completion(true, nil)
        } fail: { code, desc in
            let errorDesc = desc ?? ""
            let error = NSError(domain: TXIMMessageErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: errorDesc])
            completion(false, error)
        }
        return true
    }
    
    public func forwardMessages(_ messages: [TXIMMessage]) {
        var count = messages.count
        var forwardMessageList: [TXIMMessage] = []
        let completion: () -> Void = {
            count -= 1
            if count == 0 {
                self.notifyMessagesForward(forwardMessageList)
            }
        }
        let messagesList = messages.sorted(by: { $0.timestamp.timeIntervalSince1970 < $1.timestamp.timeIntervalSince1970 } )
        for originMsg in messagesList {
            if let tempMsg = imManager.createForwardMessage(originMsg.message) {
                var message = tempMsg
                configMessage(message: &message)
                let forwardMsg = addSentMessage(message)
                imManager.send(message, receiver: userId, groupID: nil, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: pushInfo, progress: nil) {
                    forwardMsg.updateMessage(message: message)
                    forwardMessageList.append(forwardMsg)
                    completion()
                } fail: { _, _ in
                    forwardMsg.updateMessage(message: message)
                    forwardMessageList.append(forwardMsg)
                    completion()
                }
            } else {
                completion()
            }
        }
    }
}

// MARK: Message Send

extension TXIMMessageManager {
    public func sentLockMessage(isLock: Bool) {
        let text =  isLock ? "Kamu mem-blok kontak ini, ketuk untuk mengubah" : "Kamu mumbuka blokir kontak ini"
        let myId = TXIMUserManger.shared.currentUserId
        if let message = imManager.createTextMessage(text) {
            imManager.insertC2CMessage(toLocalStorage: message, to: userId, sender: myId, succ: nil, fail: nil)
            let msg = addSentMessage(message)
            self.notifyMessagesSent(msg)
        }
    }
    
    @discardableResult public func sendTextMessage(with text: String, quote quoteMsg: TXIMMessage? = nil) -> TXIMMessage? {
        var message = imManager.createTextMessage(text)
        guard let _ = message else {
            return nil
        }
        
        configMessage(message: &message!, with: quoteMsg)
        let msg = addSentMessage(message!)
        self.notifyMessagesSent(msg)
        imManager.send(message, receiver: userId, groupID: nil, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: pushInfo, progress: nil) { [weak self] in
            if let self {
                self.updateSentMessage(msg, txmessage: message!, error: nil)
            }
        } fail: { [weak self] code, desc in
            if let self {
                let errorDesc = desc ?? ""
                let error = NSError(domain: TXIMMessageErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: errorDesc])
                self.updateSentMessage(msg, txmessage: message!, error: error)
            }
        }
        return msg
    }
    
    @discardableResult public func sendImageMessage(with imageData: Data, size: CGSize = CGSizeZero, quote quoteMsg: TXIMMessage? = nil, progress: @escaping (UInt32) -> Void) -> TXIMMessage? {
        let destPath = saveImage(imageData: imageData)
        if destPath == nil {
            return nil
        }
        
        var message = imManager.createImageMessage(destPath)
        guard let _ = message else {
            print("【DM】send media message nil")
            return nil
        }
        
        configMessage(message: &message!, with: quoteMsg)
        let msg = addSentMessage(message!)
        msg.imageWidth = Int32(size.width)
        msg.imageHeight = Int32(size.height)
        self.notifyMessagesSent(msg)
        imManager.send(message, receiver: userId, groupID: nil, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: pushInfo, progress: progress) { [weak self] in
            if let self {
                self.updateSentMessage(msg, txmessage: message!, error: nil)
            }
        } fail: { [weak self] code, desc in
            if let self {
                let errorDesc = desc ?? ""
                let error = NSError(domain: TXIMMessageErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: errorDesc])
                self.updateSentMessage(msg, txmessage: message!, error: error)
            }
        }
        return msg
    }
    
    @discardableResult public func sendVideoMessage(with videoData: Data, size: CGSize = CGSizeZero, quote quoteMsg: TXIMMessage? = nil, progress: @escaping (UInt32) -> Void) -> TXIMMessage? {
        let destPath = saveVideo(videoData: videoData)
        if destPath == nil {
            return nil
        }
        
        let url = URL(fileURLWithPath: destPath!)
        let asset = AVURLAsset(url: url, options: nil)
        let duration = Int32(asset.duration.value) / asset.duration.timescale
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        imgGenerator.maximumSize = CGSize(width: 180, height: 180)
        
        var thumbnailPath: String? = nil
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            let jpegData = thumbnail.jpegData(compressionQuality: 1.0)
            thumbnailPath = saveThumbnail(thumbnailData: jpegData)
        } catch {
            
        }
        
        var message = imManager.createVideoMessage(destPath, type: "mp4", duration: duration, snapshotPath: thumbnailPath)
        guard let _ = message else {
            print("【DM】send media message nil")
            return nil
        }
        
        configMessage(message: &message!, with: quoteMsg)
        let msg = addSentMessage(message!)
        msg.imageWidth = Int32(size.width)
        msg.imageHeight = Int32(size.height)
        self.notifyMessagesSent(msg)
        imManager.send(message, receiver: userId, groupID: nil, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: pushInfo, progress: progress) { [weak self] in
            if let self {
                self.updateSentMessage(msg, txmessage: message!, error: nil)
            }
        } fail: { [weak self] code, desc in
            if let self {
                let errorDesc = desc ?? ""
                let error = NSError(domain: TXIMMessageErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: errorDesc])
                self.updateSentMessage(msg, txmessage: message!, error: error)
            }
        }
        return msg
    }
    
    private func saveImage(imageData: Data) -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let dirPath = (documentsDirectory as NSString).appendingPathComponent("/com_tencent_imsdk_data/image/")
        if !FileManager.default.fileExists(atPath: dirPath) {
            try? FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let imageName = "image_" + String(Int(Date().timeIntervalSince1970)) + "_" + String(arc4random() % 1000) + ".jpeg"
        let filePath = (dirPath as NSString).appendingPathComponent(imageName)
        do {
            try imageData.write(to: NSURL.fileURL(withPath: filePath))
            print("【DM】Data was written to \(filePath)")
            return filePath
        } catch {
            print("【DM】Error writing data to file: \(error)")
            return nil
        }
    }
    
    private func saveVideo(videoData: Data) -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let dirPath = (documentsDirectory as NSString).appendingPathComponent("/com_tencent_imsdk_data/video/")
        if !FileManager.default.fileExists(atPath: dirPath) {
            try? FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let imageName = "video_" + String(Int(Date().timeIntervalSince1970)) + "_" + String(arc4random() % 1000) + ".mp4"
        let filePath = (dirPath as NSString).appendingPathComponent(imageName)
        do {
            try videoData.write(to: NSURL.fileURL(withPath: filePath))
            print("【DM】Data was written to \(filePath)")
            return filePath
        } catch {
            print("【DM】Error writing data to file: \(error)")
            return nil
        }
    }
    
    private func saveThumbnail(thumbnailData: Data?) -> String? {
        guard thumbnailData != nil else {
            return nil
        }
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let dirPath = (documentsDirectory as NSString).appendingPathComponent("/com_tencent_imsdk_data/thumbnail/")
        if !FileManager.default.fileExists(atPath: dirPath) {
            try? FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let imageName = "thumbnail_" + String(Int(Date().timeIntervalSince1970)) + "_" + String(arc4random() % 1000) + ".jpeg"
        let filePath = (dirPath as NSString).appendingPathComponent(imageName)
        do {
            try thumbnailData!.write(to: NSURL.fileURL(withPath: filePath))
            print("【DM】Data was written to \(filePath)")
            return filePath
        } catch {
            print("【DM】Error writing data to file: \(error)")
            return nil
        }
    }
    
    private func configMessage(message: inout V2TIMMessage, with quoteMsg: TXIMMessage? = nil) {
        var result: [String: Any] = [:]
        if isPaidChat {
            let dataObject: [String: Any] = [
                "type": "paidChat",
                "isPaid": true,
                "payerId": balance?.payerId ?? ""
            ]
            let jsonObject: [String: Any] = [
                "code": "1000",
                "message": "General Success",
                "data": dataObject
            ]
            result["modifiedData"] = jsonObject
        }
        if let quoteMsg {
            var quoteInfo: [String : Any] = [:]
            quoteInfo["messageID"] = quoteMsg.msgID
            quoteInfo["messageSenderId"] = quoteMsg.userID
            quoteInfo["messageSender"] = quoteMsg.nickName
            quoteInfo["messageType"] = quoteMsg.message.elemType.rawValue
            
            result["messageReply"] = quoteInfo
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: result, options: []) {
            message.cloudCustomData = data
        }
        message.needReadReceipt = true
    }
}

// MARK: Message Reaction
extension TXIMMessageManager {
    public func addEmoji(message: TXIMMessage, emoji: String!, completion: @escaping (Bool) -> Void) {
        imManager.addMessageReaction(message.message, reactionID: emoji) {
            print("【DM】addEmoji success")
            message.addEmoji(emoji: emoji)
            completion(true)
        } fail: { _, _ in
            print("【DM】addEmoji failure")
            completion(false)
        }
    }
    
    public func removeEmoji(message: TXIMMessage, emoji: String!, completion: @escaping (Bool) -> Void) {
        imManager.removeMessageReaction(message.message, reactionID: emoji) {
            print("【DM】removeEmoji success")
            message.removeEmoji(emoji: emoji)
            completion(true)
        } fail: { _, _ in
            print("【DM】removeEmoji failure")
            completion(false)
        }
    }
    
    private func getMessageReactions(_ messages: [V2TIMMessage]) {
        imManager.getMessageReactions(messages, maxUserCountPerReaction: 2) { [weak self] resultList in
            guard let self = self else { return }
            if resultList == nil || resultList?.count == 0 {
                return
            }
            
            var map: [String: [(String, [String])]] = [:]
            for result in resultList! {
                if let msgID = result.msgID, result.resultCode == 0 {
                    var elem: [(String, [String])] = []
                    if let reactionList = result.reactionList {
                        for reaction in reactionList {
                            if let reactionId = reaction.reactionID {
                                var userIds: [String] = []
                                let totalUserCount = reaction.totalUserCount
                                if let partialUserList = reaction.partialUserList {
                                    for user in partialUserList {
                                        userIds.append(user.userID)
                                    }
                                }
                                elem.append((reactionId, userIds))
                            }
                        }
                    }
                    if elem.count > 0 {
                        map[msgID] = elem
                    }
                }
            }
            self.updateMessagesReaction(map)
        } fail: { _, _ in
            
        }
    }
    
    private func recvMessageReactionsChanged(_ changeList: [V2TIMMessageReactionChangeInfo]!) {
        var map: [String: [(String, [String])]] = [:]
        for changeInfo in changeList {
            if let msgID = changeInfo.msgID {
                var elem: [(String, [String])] = []
                for reactonInfo in changeInfo.reactionList {
                    if let reactionId = reactonInfo.reactionID {
                        var userIds: [String] = []
                        let userList: [V2TIMUserInfo] = reactonInfo.partialUserList
                        for user in userList {
                            userIds.append(user.userID)
                        }
                        if userIds.count > 0 {
                            elem.append((reactionId, userIds))
                        }
                    }
                }
                map[msgID] = elem
            }
        }
        updateMessagesReaction(map)
    }
    
    private func updateMessagesReaction(_ reactionMap: [String: [(String, [String])]]) {
        print("【DM】reaction map \(reactionMap)")
        serialQueue.async {
            for msgId in reactionMap.keys {
                if let msg = self.messages.filter({ $0.msgID == msgId }).first {
                    msg.reactions = reactionMap[msgId]!
                }
            }
        }
    }
}

// MARK: Message read
extension TXIMMessageManager {
    
    public func clearAllUnreadCount() {
        clearUnreadCount(before: 0)
    }
    
    public func clearUnreadCount(before cleanTimestamp: UInt64) {
        guard cleanTimestamp == 0 || cleanTimestamp > self.cleanTimestamp else {
            return
        }
        self.cleanTimestamp = cleanTimestamp > 0 ? cleanTimestamp : UInt64(self.messages.last?.timestamp.timeIntervalSince1970 ?? 0)
        let convID = "c2c_" + userId
        imManager.cleanConversationUnreadMessageCount(convID, cleanTimestamp: cleanTimestamp, cleanSequence: 0, succ: nil, fail: nil)
    }
    
    public func clearHistoryMessage() {
        imManager.clearC2CHistoryMessage(userId) { [weak self] in
            guard let self else { return }
            self.clearAllMessages()
        } fail: { _, _ in
            
        }
    }
    
    public func sendMessageReadReceipts(_ messages: [TXIMMessage]) {
        print("【DM】sendMessageReadReceipts")
        let array: [V2TIMMessage] = messages.map({ $0.message }).filter( { $0.needReadReceipt == true && $0.isSelf == false } )
        if array.count > 0 {
            imManager.sendMessageReadReceipts(array) {
                print("【DM】sendMessageReadReceipts success")
            } fail: { code, desc in
                print("【DM】sendMessageReadReceipts failure \(code) \(desc ?? "")")
            }
        }
    }
    
    private func getMessageReadReceipts(_ messages: [V2TIMMessage]) {
        imManager.getMessageReadReceipts(messages) { [weak self] receipts in
            guard let self = self else { return }
            if receipts == nil || receipts?.count == 0 {
                return
            }
            
            var redMsgs: [String] = []
            for receipt in receipts! {
                if receipt.isPeerRead {
                    redMsgs.append(receipt.msgID)
                }
            }
            
            updateMessagesReadReceipts(redMsgs)
        } fail: { _, _ in
            
        }
    }
    
    private func recvMessageRead(_ receiptList: [V2TIMMessageReceipt]!) {
        print("【DM】updateMessagesReadReceipts")
        var redMsgs: [String] = []
        for receipt in receiptList {
            if receipt.isPeerRead {
                redMsgs.append(receipt.msgID)
                print("【DM】updateMessagesReadReceipts \(receipt.msgID) is read")
            }
        }
        
        updateMessagesReadReceipts(redMsgs)
    }
    
    private func updateMessagesReadReceipts(_ receipts: [String]) {
        serialQueue.async {
            for msgId in receipts {
                if let msg = self.messages.filter({ $0.msgID == msgId }).first {
                    msg.isRead = true
                }
            }
        }
    }
}

// MARK: Message List Excute
extension TXIMMessageManager {
    private func insertOldMessages(messages: [V2TIMMessage], completion: @escaping (Int32, [V2TIMMessage]) -> Void) {
        serialQueue.async {
            var sum: Int32 = 0
            var msgList: [V2TIMMessage] = []
            for message in messages {
                if self.isMessageSupport(message) {
                    sum += 1
                    msgList.insert(message, at: 0)
                    let msg = TXIMMessage(message: message)
                    self.messages.insert(msg, at: 0)
                }
            }
            completion(sum, msgList)
        }
    }
    
    private func removeMessages(messages: [TXIMMessage]) {
        serialQueue.async {
            var idToIndexMap: [String: Int] = [:]
            for (index, msg) in self.messages.enumerated() {
                idToIndexMap[msg.msgID] = index
            }
            for msg in messages {
                if let index = idToIndexMap[msg.msgID] {
                    self.messages.remove(at: index)
                    idToIndexMap.removeValue(forKey: msg.msgID)
                    idToIndexMap = idToIndexMap.mapValues { $0 >= index ? $0 - 1 : $0 }
                }
            }
            self.notifyMessageDelete()
        }
    }
    
    private func clearAllMessages() {
        serialQueue.async {
            self.messages.removeAll()
            self.notifyMessagesClear()
        }
    }
    
    private func addSentMessage(_ message: V2TIMMessage) -> TXIMMessage {
        let msg = TXIMMessage(message: message)
        serialQueue.async {
            self.messages.append(msg)
        }
        return msg
    }
    
    private func updateSentMessage(_ message: TXIMMessage, txmessage: V2TIMMessage, error: NSError?) {
        serialQueue.async {
            message.updateMessage(message: txmessage)
            if let error {
                self.delegate?.messageManager(self, didMessageSentFailure: message, error: error)
            } else {
                self.delegate?.messageManager(self, didMessageSentSuccess: message)
            }
        }
    }
    
    private func addNewMessage(message: V2TIMMessage) {
        guard isMessageSupport(message) else {
            return
        }
        serialQueue.async {
            let msg = TXIMMessage(message: message)
            self.messages.append(msg)
            self.notifyMessagesReceive(msg)
        }
    }
    
    private func findMessage(_ message: V2TIMMessage) -> TXIMMessage? {
        serialQueue.sync {
            let filterMsgs = self.messages.filter({ $0.msgID == message.msgID })
            return filterMsgs.first
        }
    }
    
    private func findMessage(messageId: String) -> TXIMMessage? {
        serialQueue.sync {
            let filterMsgs = self.messages.filter({ $0.msgID == messageId })
            return filterMsgs.first
        }
    }
}

// MARK: Message Notify
extension TXIMMessageManager {
    private func notifyMessagesUpdate() {
        DispatchQueue.main.async {
            self.delegate?.messageManager(self, didMessageUpdate: self.messages)
        }
    }
    
    private func notifyMessagesClear() {
        DispatchQueue.main.async {
            self.delegate?.didMessageClear(with: self)
        }
    }
    
    private func notifyMessageDelete() {
        DispatchQueue.main.async {
            self.delegate?.messageManager(self, didMessageDelete: self.messages)
        }
    }
    
    private func notifyMessagesReceive(_ message: TXIMMessage) {
        DispatchQueue.main.async {
            self.delegate?.messageManager(self, didMessageReceive: message)
        }
    }
    
    private func notifyMessagesSent(_ message: TXIMMessage) {
        DispatchQueue.main.async {
            self.delegate?.messageManager(self, didMessageSent: message)
        }
    }
    
    private func notifyMessagesForward(_ messages: [TXIMMessage]) {
        DispatchQueue.main.async {
            self.delegate?.messageManager(self, didMessageForward: messages)
        }
    }
    
    private func notifyMessageRevoke() {
        DispatchQueue.main.async {
            self.delegate?.didMessageRevoke(with: self)
        }
    }
}

// MARK: Message Paid
extension TXIMMessageManager {
    public func sendCustomMessage(startPaidChat: Bool) {
        notifyPaidChatStatusChanged(isPiad: startPaidChat)
        
        var data: [String : Any] = [:]
        data["type"] = "paidChat"
        data["isPaid"] = startPaidChat
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])
        let message = imManager.createCustomMessage(jsonData)
        guard let message = message else {
            return
        }
        
        message.isExcludedFromUnreadCount = true
        imManager.send(message, receiver: userId, groupID: nil, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: pushInfo, progress: nil) { print("【DM】send custom msg success") } fail: { _,_  in print("【DM】send custom msg failure") }
    }
    
    private func notifyPaidChatStatusChanged(isPiad: Bool) {
        guard isPiad != self.isPaidChat else {
            return
        }
        self.isPaidChat = isPiad
        DispatchQueue.main.async {
            self.delegate?.messageManager(self, didPaidChatStatusChanged: isPiad)
        }
    }
    
    private func notifyReceiveCloudCustomData(_ data: Data?) {
        guard let data,
              let jsonObject = TXIMMessage.modifiedDataFromCloudCustomData(data),
              let dataObject = jsonObject["data"] as? [String : Any],
              let dataObjectData = try? JSONSerialization.data(withJSONObject: dataObject, options: []),
              let balance = try? JSONDecoder().decode(PaidSessionBalance.self, from: dataObjectData) else {
            return
        }
        
        self.balance = balance
        DispatchQueue.main.async {
            self.delegate?.messageManager(self, didReceiveCloudCustomData: balance)
        }
    }
}

// MARK: - IMAdvancedMsgListener
extension TXIMMessageManager: V2TIMAdvancedMsgListener {
    public func onRecvNewMessage(_ msg: V2TIMMessage!) {
        guard let userId = msg.userID, userId == self.userId else {
            return
        }
        
        print("【DM】onRecvNewMessage")
        addNewMessage(message: msg)
        
        notifyReceiveCloudCustomData(msg.cloudCustomData)
        
        if msg.elemType == .ELEM_TYPE_CUSTOM {
            let isPaid = TXIMMessage.serializeCustomMessageData(msg.customElem.data)
            notifyPaidChatStatusChanged(isPiad: isPaid)
        } else {
            let data = TXIMMessage.modifiedDataFromCloudCustomData(msg.cloudCustomData)
            let info = data?["data"] as? [String: Any]
            let isPaid = info?["isPaid"] as? Bool ?? false
            notifyPaidChatStatusChanged(isPiad: isPaid)
        }
    }
    
    public func onRecvMessageModified(_ msg: V2TIMMessage!) {
        guard let userId = msg.userID, userId == self.userId, let data = msg.cloudCustomData else {
            return
        }
        
        print("【DM】onRecvMessageModified")
        
        if let message = findMessage(msg) {
            message.messageModify(msg)
        }
        
        notifyReceiveCloudCustomData(data)
    }
    
    public func onRecvMessageRevoked(_ msgID: String!, operateUser: V2TIMUserFullInfo!, reason: String!) {
        print("【DM】onRecvMessageRevoked：\(reason ?? "")")
        
        if let message = findMessage(messageId: msgID) {
            message.isRevoke = true
            notifyMessageRevoke()
        }
    }
    
    public func onRecvMessageReactionsChanged(_ changeList: [V2TIMMessageReactionChangeInfo]!) {
        print("【DM】onRecvMessageReactionsChanged")
        for changeInfo in changeList {
            if let msgID = changeInfo.msgID {
                if let message = findMessage(messageId: msgID) {
                    self.getMessageReactions([message.message])
                }
            }
        }
//        recvMessageReactionsChanged(changeList)
    }
    
    public func onRecvMessageRead(_ receiptList: [V2TIMMessageReceipt]!) {
        print("【DM】onRecvMessageRead")
        
        recvMessageRead(receiptList)
    }
}
