import Foundation
import Combine
import KipasKipasDirectMessage

public final class PaidChatPriceInteractorAdapter {
    
    typealias PriceResult = Swift.Result<Int, Error>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (String) -> PaidChatPriceLoader
    
    init(loader: @escaping (String) -> PaidChatPriceLoader) {
        self.loader = loader
    }
    
    func load(by userId: String, completion: @escaping (PriceResult) -> Void) {
        cancellable = loader(userId)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case .finished: break
                }
            }, receiveValue: { response in
                completion(.success(response.data.chatPrice ?? 0))
            })
    }
}
