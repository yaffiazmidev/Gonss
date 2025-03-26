//
//  DirectMessageContainerInteractor.swift
//  KipasKipasDirectMessageUI
//
//  Created by MissYasiky on 2024/3/20.
//

import Foundation
import KipasKipasDirectMessage
import KipasKipasNetworking

public protocol DirectMessageContainerInteractorDelegate: AnyObject {
    func directMessageInteractor(didTotalUnreadMessageCountChanged totalUnreadCount: UInt64)
    func directMessageInteractor(didConversationUpdate conversations: [TXIMConversation])
    func directMessageInteractor(didReceiveError error: Error)
    
    func lockConversationSuccess(isSucess:Bool, message: String)
}

class DirectMessageContainerInteractor: NSObject {
    weak var delegate: DirectMessageContainerInteractorDelegate?
     var network: DataTransferService!
    var authToken:String = ""
    
    private lazy var convManager: TXIMConversationManager = {
        let manager = TXIMConversationManager()
        manager.delegate = self
        return manager
    }()
    
    public var conversations: [TXIMConversation] = []
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveConversationLock), name: .init("onReceiveConversationLock"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func loadMoreConversations() {
        convManager.loadNexPageConversations()
    }
    
    public func getTotalUnreadMessageCount() {
        convManager.getTotalUnreadMessageCount()
    }
    
    public func clearUnreadCount(_ conversation: TXIMConversation) {
        convManager.clearUnreadCount(conversation)
    }
    
    public func addUnreadMark(conversationId: String) {
        convManager.unreadConversations(convIds: [conversationId], isMark: true)
    }
    
    public func pinConversation(conversation: TXIMConversation){
        convManager.pinConversation(conversation: conversation)
    }
    
    public func foldConversation(conversation: TXIMConversation){
        convManager.foldConversations(convIds: [conversation.convID], isMark: !conversation.isFold)
        if conversation.isPin {
            convManager.pinConversation(conversation: conversation)
        }
    }
    
    public func deleteConversations(_ convIds: [String]){
        convManager.deleteConversations(convIds: convIds)
    }
    
    
    
    
    public func defriend(with conversation: TXIMConversation, report:Bool ) {
        struct Root: Codable {
            var code: String?
            var message: String?
        }
        
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "blockRelationship",
            method: .post,
            bodyParamaters: ["accountId": conversation.userID, "report":report]
        )
        
        network?.request(with: endpoint) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure(let error):
                print("Failed:  defriend - \(error.message ?? "")")
                self?.delegate?.lockConversationSuccess(isSucess: false, message: error.message ?? "")
            case .success(let response):
                print("success: defriend - \(response?.message ?? "")")
                self?.convManager.markLockConversation(conversation.convID, isMark: true)
                self?.delegate?.lockConversationSuccess(isSucess: true, message: "")
            }
        }
    }
    
    public func removeDefriend(conversation: TXIMConversation) {
        struct Root: Codable {
            var code: String?
            var message: String?
        }
        
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "blockRelationship",
            method: .put,
            headerParamaters: ["Authorization" : "Bearer \(authToken)", "Content-Type":"application/json"],
            bodyParamaters: ["accountId": conversation.userID, "enabled":false]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure(let error):
                print("Failed:  removeDefriend - \(error.message ?? "")")
                self?.delegate?.lockConversationSuccess(isSucess: false, message: error.message ?? "")
            case .success(let response):
                print("success: removeDefriend - \(response?.message ?? "")")
                self?.convManager.markLockConversation(conversation.convID, isMark: false)
                self?.delegate?.lockConversationSuccess(isSucess: true, message: "")
            }
        }
    }
    
    @objc func onReceiveConversationLock(_ notification: Notification) {
        guard let object = notification.object as? String else { return }
        self.convManager.markLockConversation(object, isMark: false, sentLockMsg: false)
    }
}

extension DirectMessageContainerInteractor: TXIMConversationManagerDelegate {
    public func conversationManager(_ conversationManager: TXIMConversationManager, didTotalUnreadMessageCount totalUnreadCount: UInt64) {
//        self.delegate?.directMessageInteractor(didTotalUnreadMessageCountChanged: totalUnreadCount)
    }
    
    public func conversationManager(_ conversationManager: TXIMConversationManager, didConversationUpdate conversations: [TXIMConversation]) {
        self.conversations = conversations
        self.delegate?.directMessageInteractor(didConversationUpdate: conversations)
        
        
        let unReadSonvs =  self.conversations.filter{ $0.unreadCount > 0 || $0.isUnread }
        self.delegate?.directMessageInteractor(didTotalUnreadMessageCountChanged: UInt64(unReadSonvs.count))
    }
    
    public func conversationManager(_ conversationManager: TXIMConversationManager, didReceiveError error: Error) {
        self.delegate?.directMessageInteractor(didReceiveError: error)
    }
}
