import Foundation
import Combine
import KipasKipasDirectMessage

public final class ChatProfileInteractorAdapter {
    
    typealias ChatProfileResult = Swift.Result<ChatProfile, DirectMessageError>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (String) -> ChatProfileLoader
    
    init(
        loader: @escaping (String) -> ChatProfileLoader
    ) {
        self.loader = loader
    }
    
    func load(
        with username: String,
        completion: @escaping (ChatProfileResult) -> Void
    ) {
        cancellable = loader(username)
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
