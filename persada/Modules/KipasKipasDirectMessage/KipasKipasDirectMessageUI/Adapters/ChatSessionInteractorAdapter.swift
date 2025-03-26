import Foundation
import Combine
import KipasKipasDirectMessage

public final class ChatSessionInteractorAdapter {
    
    typealias ChatSessionResult = Swift.Result<ChatSession, DirectMessageError>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (ChatChannelParam, ChatParam) -> ChatSessionLoader
    
    init(loader: @escaping (ChatChannelParam, ChatParam) -> ChatSessionLoader) {
        self.loader = loader
    }
    
    func load(
        channelParam: ChatChannelParam,
        chatParam: ChatParam,
        completion: @escaping (ChatSessionResult) -> Void
    ) {
        cancellable = loader(channelParam, chatParam)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case .finished: break
                }
            }, receiveValue: { response in
                completion(.success(response))
            })
    }
}
