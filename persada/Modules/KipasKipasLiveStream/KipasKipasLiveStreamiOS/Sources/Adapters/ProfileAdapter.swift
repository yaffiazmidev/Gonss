import Combine
import KipasKipasNetworking
import KipasKipasLiveStream
import KipasKipasShared

protocol ProfileAdapterDelegate: AnyObject {
    func profileResult(_ result: Result<LiveUserProfile, Error>)
}

final class ProfileAdapter {
    
    private let loader: () -> LiveProfileLoader
    
    private var cancellable: AnyCancellable?
    
    weak var delegate: ProfileAdapterDelegate?
    
    init(loader: @escaping () -> LiveProfileLoader) {
        self.loader = loader
    }
    
    func loadProfile() {
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case let .failure(error) = result {
                    self?.delegate?.profileResult(.failure(error))
                }
            }, receiveValue: { [weak self] response in
                self?.delegate?.profileResult(.success(response.data))
            })
    }
}
