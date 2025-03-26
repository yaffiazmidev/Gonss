import Foundation
import Combine
import KipasKipasShared
import KipasKipasLiveStream

final class LiveDailyRankPresentationAdapter {
    
    private let loader: () -> DailyRankLoader
    private let popularLiveLoader: () -> DailyRankLoader
    private var cancellable: AnyCancellable?
    
    var presenter: LiveDailyRankPresenter?
    
    init(loader: @escaping () -> DailyRankLoader, popularLiveLoader: @escaping () -> DailyRankLoader) {
        self.loader = loader
        self.popularLiveLoader = popularLiveLoader
    }
    
    func loadDailyRank() {
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.presenter?.didFinishRequest(with: [])
                }
            }, receiveValue: { [weak self] response in 
                self?.presenter?.didFinishRequest(with: response.data)
            })
    }
    
    func loadPopularLive() {
        cancellable = popularLiveLoader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.presenter?.didFinishPopularRequest(with: [])
                }
            }, receiveValue: { [weak self] response in
                self?.presenter?.didFinishPopularRequest(with: response.data)
            })
    }
}
