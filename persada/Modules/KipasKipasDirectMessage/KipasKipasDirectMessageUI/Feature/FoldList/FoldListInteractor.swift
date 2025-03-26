import UIKit
import KipasKipasDirectMessage
import KipasKipasNetworking

protocol FoldListInteractorDelegate: AnyObject {
    func didConversationsUpdate(_ conversations: [TXIMConversation])
    func lockConversationSuccess(isSucess:Bool, message: String)
}

class FoldListInteractor: NSObject {
    weak var delegate: FoldListInteractorDelegate?
    private let isPaidOnly: Bool
    var network: DataTransferService!
    var authToken: String = ""
    
    private lazy var convManager: TXIMConversationManager = {
        let manager = TXIMConversationManager()
        manager.delegate = self
        return manager
    }()
    
    public var conversations: [TXIMConversation] = []
    
    init(
        isPaidOnly: Bool 
    ) {
        self.isPaidOnly = isPaidOnly
    }
    
    public func loadMoreConversations() {
        convManager.loadNexPageConversations()
    }
    
    
//    func didConversationsUpdate(_ conversations: [TXIMConversation]){
//        
//    }
    
    func clearUnreadCount(_ conversation: TXIMConversation){
        convManager.clearUnreadCount(conversation)
    }
    
    func didUnfoldHandleConversations(_ conversations: [String],isMark:Bool){
        convManager.foldConversations(convIds: conversations, isMark: isMark)
    }
    
    func didUnreadHandleConversations(_ convIds: [String],isMark:Bool){
        convManager.unreadConversations(convIds: convIds, isMark: isMark)
    }
    
    func didDeleteConversations(_ convIds: [String]){
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
     
}

extension FoldListInteractor: TXIMConversationManagerDelegate {
    public func conversationManager(_ conversationManager: TXIMConversationManager, didTotalUnreadMessageCount totalUnreadCount: UInt64) {
        
        
//        self.delegate?.directMessageInteractor(didTotalUnreadMessageCountChanged: totalUnreadCount)
    }
    
    public func conversationManager(_ conversationManager: TXIMConversationManager, didConversationUpdate conversations: [TXIMConversation]) {
        print("FoldList ------  paid \(isPaidOnly)")
        if isPaidOnly {
            self.conversations = conversations.filter { $0.isPaid == true && $0.isFold == true }
        } else {
            self.conversations = conversations.filter { $0.isFold == true }
        }
        self.delegate?.didConversationsUpdate(self.conversations)
        
//        self.conversations = conversations
//        self.delegate?.directMessageInteractor(didConversationUpdate: conversations)
    }
    
    public func conversationManager(_ conversationManager: TXIMConversationManager, didReceiveError error: Error) {
//        self.delegate?.directMessageInteractor(didReceiveError: error)
    }
}
