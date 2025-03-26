import Combine
import KipasKipasShared
import KipasKipasLiveStream

public final class ListActiveLiveStreamPresentationAdapter {
    
    private let profileLoader: () -> LiveProfileLoader
    private let loader: () -> ListLiveRoomLoader
    
    private var cancellables: Set<AnyCancellable> = []
    
    public var presenter: ListActiveLiveStreamPresenter?
    
    public init(
        profileLoader: @escaping () -> LiveProfileLoader,
        loader: @escaping () -> ListLiveRoomLoader
    ) {
        self.profileLoader = profileLoader
        self.loader = loader
    }
    
    public func load() {
        profileLoader()
            .dispatchOnMainQueue()
            .sinkIgnoreCompletion()
            .store(in: &cancellables)
        
        loader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished: break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
            }, receiveValue: { [weak self] root in 
                self?.presenter?.didFinishLoading(with: root.data)
            })
            .store(in: &cancellables)
    }
}
