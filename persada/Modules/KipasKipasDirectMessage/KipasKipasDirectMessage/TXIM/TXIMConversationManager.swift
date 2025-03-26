//
//  TXIMConversationManager.swift
//  KipasKipasDirectMessage
//
//  Created by MissYasiky on 2024/3/15.
//

import Foundation
import ImSDK_Plus

let TXIMConversationPageSize: UInt32 = 100
let TXIMConversationErrorDomain = "com.kipaskipas.TXIMConversationManager"

/// 会话标记类型   
enum  TXV2TIMConversationMarkType : UInt {
    case CONVERSATION_MARK_TYPE_LOCK = 1     //< 会话拉黑
//    case CONVERSATION_MARK_TYPE_STAR = 1   //< 会话标星
    case CONVERSATION_MARK_TYPE_UNREAD = 2     //< 会话标记未读（重要会话）
    case CONVERSATION_MARK_TYPE_FOLD = 4    //< 会话折叠
    case CONVERSATION_MARK_TYPE_HIDE = 8     //< 会话隐藏
    
};

public protocol TXIMConversationManagerDelegate: NSObject {
    func conversationManager(_ conversationManager: TXIMConversationManager, didTotalUnreadMessageCount totalUnreadCount: UInt64)
    func conversationManager(_ conversationManager: TXIMConversationManager, didConversationUpdate conversations: [TXIMConversation])
    func conversationManager(_ conversationManager: TXIMConversationManager, didReceiveError error: Error)
}

public final class TXIMConversationManager: NSObject {
    
    weak public var delegate: TXIMConversationManagerDelegate?
    public var isLastPage: Bool = false
    
    private(set) var conversationList: [TXIMConversation] = []
    private let pageSize: UInt32 = TXIMConversationPageSize
    private var pageIndex: UInt64 = 0
    private var totalUnreadCountChangedHandler: ((UInt64) -> Void)?
    private let serialQueue = DispatchQueue(label: TXIMConversationErrorDomain)
    private var sortBlock: ((TXIMConversation, TXIMConversation) -> Bool)!
    private(set) lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
    }()
    
    private(set) lazy var filter: V2TIMConversationListFilter = {
        let convfilter = V2TIMConversationListFilter()
        convfilter.type = .C2C
        return convfilter
    }()
    
    public override init() {
        super.init()
        imManager.addConversationListener(listener: self)
        NotificationCenter.default.addObserver(self, selector: #selector(userInfoChanged(notification:)), name: .init("getUserInfo"), object: nil)
        sortBlock = sortConversation
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("【DM】deinit TXIMConversationManager")
    }
    
    public func getTotalUnreadMessageCount() {
        getTotalUnreadMessageCount { _ in }
    }
    
    public func getTotalUnreadMessageCount(completion: @escaping ((UInt64) -> Void)) {
        self.totalUnreadCountChangedHandler = completion
        
        imManager.getTotalUnreadMessageCount { [weak self] totalUnreadCount in
            print("【DM】getTotalUnreadMessageCount \(totalUnreadCount)")
            if let self {
                self.getFilterUnreadMessageCount()
            }
        } fail: { code, desc in
            print("【DM】getTotalUnreadMessageCount error \(code)-\(desc ?? "")")
        }
    }
    
    private func getFilterUnreadMessageCount() {
        imManager.getUnreadMessageCount(by: filter) { [weak self] totalUnreadCount in
            print("【DM】getFilterUnreadMessageCount \(totalUnreadCount)")
            if let self {
                self.totalUnreadCountChangedHandler?(totalUnreadCount)
                self.delegate?.conversationManager(self, didTotalUnreadMessageCount: totalUnreadCount)
            }
        } fail: { code, desc in
            print("【DM】getFilterUnreadMessageCount error \(code)-\(desc ?? "")")
        }
    }
    
    public func clearUnreadCount(_ conversation: TXIMConversation) {
        let conversationId = conversation.convID
        if conversation.unreadCount > 0 {
            imManager.cleanConversationUnreadMessageCount(conversationId, cleanTimestamp: 0, cleanSequence: 0, succ: nil, fail: nil)
        }
        if conversation.isUnread {
            let markType  = V2TIMConversationMarkType.CONVERSATION_MARK_TYPE_UNREAD.rawValue
            imManager.markConversation([conversationId], markType:NSNumber(value: markType), enableMark: false, succ: nil, fail: nil)
        }
    }
    
    public func deleteConversations(convIds: [String]){
        imManager.deleteConversationList(convIds, clearMessage: true, succ: nil, fail: nil)
    }
    
    //    MARK: -  markType
  
    public func pinConversation(conversation: TXIMConversation) {
        imManager.pinConversation(conversation.convID, isPinned: !conversation.isPin, succ: nil, fail: nil)
    }
    
    public func foldConversations(convIds: [String], isMark:Bool) {
        let markType  = TXV2TIMConversationMarkType.CONVERSATION_MARK_TYPE_FOLD.rawValue
        imManager.markConversation(convIds, markType: NSNumber(value: markType), enableMark: isMark, succ: nil, fail: nil)
    }
    
    public func unreadConversations(convIds: [String], isMark:Bool) {
       convIds.forEach { convId in
        imManager.cleanConversationUnreadMessageCount(convId, cleanTimestamp: 0, cleanSequence: 0, succ: nil, fail: nil)
        }
        
        let markType  = TXV2TIMConversationMarkType.CONVERSATION_MARK_TYPE_UNREAD.rawValue
        imManager.markConversation(convIds, markType: NSNumber(value: markType), enableMark: isMark, succ: nil, fail: nil)
    }
   
     
    public func markLockConversation(_ convId: String,isMark:Bool, sentLockMsg: Bool = true) {
       let markType  = TXV2TIMConversationMarkType.CONVERSATION_MARK_TYPE_LOCK.rawValue
       imManager.markConversation([convId], markType:NSNumber(value: markType), enableMark: isMark, succ: nil, fail: nil)
        if sentLockMsg {
            sentLockMessage(convId: convId, isLock: isMark)
        }
    }
    
    //    MARK: -   send lock message
    public func sentLockMessage(convId :String ,isLock:Bool){
       let text =  isLock ? "Kamu mem-blok kontak ini, ketuk untuk mengubah" : "Kamu mumbuka blokir kontak ini"
        let myId = TXIMUserManger.shared.currentUserId
        let toId = (convId as NSString).substring(from: 4)
        
        if let message = imManager.createTextMessage(text) {
            imManager.insertC2CMessage(toLocalStorage: message, to: toId, sender: myId, succ: nil, fail: nil)
        }
          
    }
    
    
    public func loadNexPageConversations() {
        guard isLastPage == false else {
            return
        }
        imManager.getConversationList(by: filter, nextSeq: pageIndex, count: pageSize) { [weak self] list, nextSeq, isFinished in
            self?.pageIndex = nextSeq
            self?.isLastPage = isFinished
            if let self {
                self.addConversations(list)
            }
        } fail: { [weak self] code, desc in
            if let self {
                let errorDesc = "loadNexPageConversations-\(desc ?? "null")"
                let error = NSError(domain: TXIMConversationErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: errorDesc])
                self.delegate?.conversationManager(self, didReceiveError: error)
            }
        }
    }
    
    private func getUsersInfo(with conversations: [TXIMConversation]) {
        print("【DM】start getUsersInfo conversation count \(conversations.count)")
        var userIdList: [String] = []
        for conv in conversations {
            userIdList.append(conv.userID)
        }
        print("【DM】start getUsersInfo userId count \(userIdList.count)")
        TXIMUserManger.shared.getUsersInfo(userIdList) { _ in } failure: { _ in }
    }
    
    @objc func userInfoChanged(notification: NSNotification) {
        guard let obj = notification.object as? [TXIMUser] else {
            return
        }
        updateUserInfo(userInfos: obj)
    }
}

// Message List Change Related
extension TXIMConversationManager {
    private func updateUserInfo(userInfos: [TXIMUser]) {
        serialQueue.async {
            var userMap: [String: TXIMUser] = [:]
            for user in userInfos {
                if user.userID.count > 0 {
                    userMap[user.userID] = user
                }
            }
            for conv in self.conversationList {
                if let user = userMap[conv.userID] {
                    conv.nickName = user.nickName
                    conv.faceURL = user.faceURL
                    conv.isVerified = user.isVerified
                }
            }
            self.notifyConversationChange()
        }
    }
    
    private func addConversations(_ conversations: [V2TIMConversation]?) {
        if let conversations, conversations.count > 0 {
            updateConversations(conversations)
        } else {
            self.notifyConversationChange()
        }
    }
    
    private func updateConversations(_ conversations: [V2TIMConversation]!) {
        guard conversations.count > 0 else {
            return
        }
        serialQueue.async {
            let filtConversations = conversations.filter( { $0.userID != TXIMUserManger.shared.currentUserId })
            var conversationMap: [String: V2TIMConversation] = [:]
            for cov in filtConversations {
                conversationMap[cov.conversationID] = cov
            }
            
            for conv in self.conversationList {
                if let updateConv = conversationMap[conv.convID] {
                    conv.updateConversation(conversation: updateConv)
                    conversationMap.removeValue(forKey: conv.convID)
                }
            }
            
            var addConvList: [TXIMConversation] = []
            for conv in conversationMap.values {
                addConvList.append(TXIMConversation(conversation: conv))
            }
            
            self.conversationList.append(contentsOf: addConvList)
            self.conversationList = self.conversationList.sorted(by: self.sortBlock)
            
            self.notifyConversationChange()
            
            self.getUsersInfo(with: addConvList)
        }
    }
    
    private func insertConversations(_ conversations: [V2TIMConversation]!) {
        serialQueue.async {
            var conversationMap: [String: V2TIMConversation] = [:]
            var conflictConvIds: [String] = []
            for cov in conversations {
                conversationMap[cov.conversationID] = cov
            }
            
            for conv in self.conversationList {
                if let updateConv = conversationMap[conv.convID] {
                    conv.updateConversation(conversation: updateConv)
                    conflictConvIds.append(conv.convID)
                    conversationMap.removeValue(forKey: conv.convID)
                }
            }
            
            let tempConvList = conversations.filter( { conflictConvIds.contains($0.conversationID) == false } ).map{ TXIMConversation(conversation: $0) }
            if tempConvList.count > 0 {
                let sortConversations = tempConvList.sorted(by: self.sortBlock)
                self.conversationList.insert(contentsOf: sortConversations, at: 0)
            }
            
            self.notifyConversationChange()
        }
    }
    
    private func deleteConversations(_ conversationIDList: [String]!) {
        serialQueue.async {
            self.conversationList = self.conversationList.filter {
                conversationIDList.contains($0.convID) == false
            }
            self.notifyConversationChange()
        }
    }
    
    private func notifyConversationChange() {
        DispatchQueue.main.async {
            self.delegate?.conversationManager(self, didConversationUpdate: self.conversationList)
        }
    }
    
    private func sortConversation(_ conv1: TXIMConversation, _ conv2: TXIMConversation) -> Bool {
        if conv1.isPaid == conv2.isPaid {
            return conv1.lastMsgTimestamp?.timeIntervalSince1970 ?? 0 > conv2.lastMsgTimestamp?.timeIntervalSince1970 ?? 0
        } else {
            return conv1.isPaid == true && conv2.isPaid == false
        }
    }
}

// MARK: - V2TIMConversationListener
extension TXIMConversationManager: V2TIMConversationListener {

    // 有新的会话（比如收到一个新同事发来的单聊消息、或者被拉入了一个新的群组中），可以根据会话的 lastMessage -> timestamp 重新对会话列表做排序。
    public func onNewConversation(_ conversationList: [V2TIMConversation]!) {
        print("【DM】TXIMConversationManager onNewConversation")
        updateConversations(conversationList)
    }

    public func onConversationChanged(_ conversationList: [V2TIMConversation]!) {
        print("【DM】TXIMConversationManager onConversationChanged")
        updateConversations(conversationList)
    }

    public func onConversationDeleted(_ conversationIDList: [String]!) {
        print("【DM】TXIMConversationManager onConversationDeleted")
        deleteConversations(conversationIDList)
    }

    public func onTotalUnreadMessageCountChanged(_ totalUnreadCount: UInt64) {
        print("【DM】TXIMConversationManager onTotalUnreadMessageCountChanged \(totalUnreadCount)")
        getFilterUnreadMessageCount()
    }
}
