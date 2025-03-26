import UIKit
import KipasKipasDirectMessage

protocol IChatPresenter {
    func presentConversations(with result: [TXIMConversation])
    func presentPaidChatUnreadCount(count: Int32)
    
    func presentFoldCount(count:Int)
    func presentFoldUnreadCount(count: Int)
}

class ChatPresenter: IChatPresenter {
	weak var controller: IChatViewController?
    
	init( controller: IChatViewController) {
		self.controller = controller
	}
    
    func presentConversations(with result: [TXIMConversation]) {
        controller?.displayConversations(result)
    }
    
    func presentPaidChatUnreadCount(count: Int32) {
        controller?.displayPaidChatUnreadCount(count: count)
    }
    
    func presentFoldCount(count: Int) {
        controller?.setFoldCount(count: count)
    }
    
     func presentFoldUnreadCount(count: Int){
         controller?.setFoldUnreadCount(count: count)
    }
}
