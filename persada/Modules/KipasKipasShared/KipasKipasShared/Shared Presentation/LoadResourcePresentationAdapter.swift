import Combine

public protocol LoadImagePresentationAdapter {
    func didRequestImages(
        urls: [URL],
        delay: TimeInterval,
        conditions: @escaping (URL) -> Bool
    ) async throws
    func didCancelImageRequest()
}

public extension LoadImagePresentationAdapter {
    func didRequestImages(urls: [URL], conditions: @escaping (URL) -> Bool) async throws {
        try await didRequestImages(urls: urls, delay: 0, conditions: conditions)
    }
    
    func didRequestImage(url: URL) async throws {
        try await didRequestImages(urls: [url], conditions: { _ in return true })
    }
}

public final class LoadResourcePresentationAdapter<Loader: ResourceLoader, View: ResourceView> {
    
    public var presenter: LoadResourcePresenter<Loader.Resource, View>?
    
    private var cancellable: Cancellable?
    
    private let loader: Loader
    
    public init(loader: Loader) {
        self.loader = loader
    }
    
    public func loadResource(with parameter: Loader.Parameter) {
        presenter?.didStartLoading()
        
        cancellable = loader.publisher(parameter)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(withError: error)
                }
            }, receiveValue: { [weak self] response in
                self?.presenter?.didFinishLoading(with: response)
            })
    }
}

extension LoadResourcePresentationAdapter: LoadImagePresentationAdapter where Loader.Parameter == URL {
    private  func didRequestImage(url: URL) async {
        Task {
            loadResource(with: url)
        }
    }
    
    public func didRequestImages(
        urls: [URL],
        delay: TimeInterval,
        conditions: @escaping (URL) -> Bool
    ) async throws {
        for url in urls {
            guard conditions(url) else { return }
            await didRequestImage(url: url)
            
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
    
    public func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
