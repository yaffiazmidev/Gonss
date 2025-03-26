
import UIKit
import KipasKipasDirectMessage
import SendbirdChatSDK
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IPaidDirectMessageRankPresenter {
    typealias CompletionHandler<T> = Swift.Result<T, DataTransferError>
    
    func presentChatRank(with result: CompletionHandler<RemoteChatRank?>)
    func presentCreateChannel(with result: CompletionHandler<GroupChannel?>)
}

class PaidDirectMessageRankPresenter: IPaidDirectMessageRankPresenter {
	weak var controller: IPaidDirectMessageRankViewController?
	
	init(controller: IPaidDirectMessageRankViewController) {
		self.controller = controller
	}
    
    func presentChatRank(with result: CompletionHandler<RemoteChatRank?>) {
        switch result {
        case.failure(let error):
            controller?.displayError(message: error.localizedDescription)
        case .success(let response):
            controller?.displayChatRank(users: response?.data ?? [])
        }
    }
    
    func presentCreateChannel(with result: CompletionHandler<GroupChannel?>) {
        switch result {
        case .failure(let error):
            controller?.displayError(message: error.message ?? "")
        case .success(let response):
            controller?.displayCreateChannel(channel: response)
        }
    }
}
