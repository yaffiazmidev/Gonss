import Foundation
import Combine
import KipasKipasDirectMessage

public final class PaidSessionBalanceInteractorAdapter {
    
    typealias PaidSessionBalanceResult = Swift.Result<PaidSessionBalance, Error>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (String) -> PaidSessionBalanceLoader
    
    init(loader: @escaping (String) -> PaidSessionBalanceLoader) {
        self.loader = loader
    }
    
    func load(_ channelId: String, completion: @escaping (PaidSessionBalanceResult) -> Void) {
        cancellable = loader(channelId)
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
