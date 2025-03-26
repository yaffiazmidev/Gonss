import Foundation
import Combine
import KipasKipasDirectMessage

final class ListFollowingInteractorAdapter {
    
    typealias ListFollowingResult = Swift.Result<DirectMessageFollowing,Error>
    
    private var cancellable: AnyCancellable?
    
    private let userId: String
    private let loader: (ListFollowingParam) -> ListFollowingLoader
    
    init(
        userId: String,
        loader: @escaping (ListFollowingParam) -> ListFollowingLoader
    ) {
        self.userId = userId
        self.loader = loader
    }
    
    func load(page: Int, completion: @escaping (ListFollowingResult) -> Void) {
        cancellable = loader(.init(
            userId: userId,
            page: page
        ))
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
