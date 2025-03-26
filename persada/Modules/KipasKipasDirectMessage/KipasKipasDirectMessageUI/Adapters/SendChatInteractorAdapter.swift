import Foundation
import Combine
import KipasKipasDirectMessage

public final class SendChatInteractorAdapter {
    
    typealias SendChatResult = Swift.Result<ChatSession, DirectMessageError>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (ChatParam) -> SendChatLoader
    
    init(loader: @escaping (ChatParam) -> SendChatLoader) {
        self.loader = loader
    }
    
    func send(
        chatParam: ChatParam,
        completion: @escaping (SendChatResult) -> Void
    ) {
        cancellable = loader(chatParam)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case .finished: break
                }
            }, receiveValue: { response in
                completion(.success(response.data))
            })
    }
}
