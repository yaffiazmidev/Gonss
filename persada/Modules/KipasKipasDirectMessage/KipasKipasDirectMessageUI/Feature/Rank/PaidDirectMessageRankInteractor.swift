import UIKit
import KipasKipasDirectMessage
import SendbirdChatSDK
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IPaidDirectMessageRankInteractor: AnyObject {
    func requestChatRank()
    func createGroupChannel(selectedId: String)
}

class PaidDirectMessageRankInteractor: IPaidDirectMessageRankInteractor {
    
    private let presenter: IPaidDirectMessageRankPresenter
    private let network: DataTransferService
    
    init(presenter: IPaidDirectMessageRankPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestChatRank() {
        
        let endpoint: Endpoint<RemoteChatRank?> = Endpoint(path: "chat/rank", method: .get)
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentChatRank(with: result)
        }
    }
    
    func createGroupChannel(selectedId: String) {
        
        struct Root: Codable {
            let code: String?
            let message: String?
        }
        
        let channelURL = [SendbirdChat.getCurrentUser()?.userId ?? "", selectedId].sorted().joined(separator: "_")
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "chat/register-account",
            method: .post,
            bodyParamaters: [
                "externalChannelId": channelURL,
                "payerId": SendbirdChat.getCurrentUser()?.userId ?? "",
                "recipientId": selectedId
            ]
        )
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.presenter.presentCreateChannel(with: .failure(error))
            case .success(_):
                CreateGroupChannelUseCase().createGroupChannel(selectedUserId: selectedId) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let response):
                        self.presenter.presentCreateChannel(with: .success(response))
                    case .failure(let error):
                        let error = NetworkError.error(statusCode: error.code, data: error.domain.data(using: .utf8))
                        self.presenter.presentCreateChannel(with: .failure(.networkFailure(error)))
                    }
                }
            }
        }
    }
}
