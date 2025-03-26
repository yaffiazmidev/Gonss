import Foundation
import Combine
import KipasKipasDirectMessage

public final class ConfirmationSetDiamondInteractorAdapter {
    
    typealias SetDiamondResult = Swift.Result<RemoteSetDiamondData, DirectMessageError>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (ChatParam) -> ConfirmationSetDiamondLoader
    
    init(loader: @escaping (ChatParam) -> ConfirmationSetDiamondLoader) {
        self.loader = loader
    }
    
    func confirm(
        chatParam: ChatParam,
        completion: @escaping (SetDiamondResult) -> Void
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
