import UIKit
import KipasKipasDirectMessage
import KipasKipasNetworking

protocol IChatInteractor: AnyObject {
    func didConversationsUpdate(_ conversations: [TXIMConversation])
    func searchConversation(with keyword: String)
}

class ChatInteractor: IChatInteractor {
     
    private let isPaidOnly: Bool
    private let presenter: IChatPresenter
    private var conversations: [TXIMConversation] = []
    private var foldConversations: [TXIMConversation] = []
    private var searchKeywords: String = ""
    
    init(
        isPaidOnly: Bool = false,
        presenter: IChatPresenter
    ) {
        self.isPaidOnly = isPaidOnly
        self.presenter = presenter
    }
     
     
    func didConversationsUpdate(_ conversations: [TXIMConversation]) {
        if isPaidOnly {
            self.foldConversations = conversations.filter { $0.isPaid == true && $0.isFold == true }
            
            self.conversations = conversations.filter { $0.isPaid == true && $0.isFold == false }
//            self.conversations = conversations.filter { $0.isPaid == true }
            updatePiadChatUnreadCount()
        } else {
            self.foldConversations = conversations.filter { $0.isFold == true }
            self.conversations = conversations.filter { $0.isFold == false }
//            self.conversations = conversations
            self.conversations = self.conversations.sorted { conv1, conv2 in
                return conv1.isPin == true && conv2.isPin == false
            }
        }
        searchingConversation(keyword: self.searchKeywords)
        presenter.presentFoldCount(count: self.foldConversations.count)
        
        var unreadCount = 0
        self.foldConversations.forEach { conv in
            if conv.unreadCount > 0 || conv.isUnread {
                unreadCount += 1
            }
        }
        
        presenter.presentFoldUnreadCount(count: unreadCount)
    }
    
     
    
    func searchConversation(with keyword: String) {
        self.searchKeywords = keyword
        searchingConversation(keyword: self.searchKeywords)
    }
    
    private func searchingConversation(keyword: String) {
        if keyword.isEmpty {
            presenter.presentConversations(with: self.conversations)
        } else {
            let result = self.conversations.filter( {$0.nickName.contains(keyword)} )
            presenter.presentConversations(with: result)
        }
    }
    
    private func updatePiadChatUnreadCount() {
        let unreadCount = self.conversations.reduce(0) { $0 + $1.unreadCount }
        presenter.presentPaidChatUnreadCount(count: unreadCount)
    }
}
