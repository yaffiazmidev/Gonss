import Foundation
import Combine
import KipasKipasDirectMessage

final class SearchUserInteractorAdapter {
    
    typealias UserResult = Swift.Result<[RemoteSearchUserData], Error>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (String) -> SearchAccountByUsernameLoader
    
    init(loader: @escaping (String) -> SearchAccountByUsernameLoader) {
        self.loader = loader
    }
    
    func search(by username: String, completion: @escaping (UserResult) -> Void) {
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
