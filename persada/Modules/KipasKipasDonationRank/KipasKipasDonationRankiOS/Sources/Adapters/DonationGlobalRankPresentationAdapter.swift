import Foundation
import KipasKipasDonationRank

final class DonationGlobalRankPresentationAdapter {
    
    var presenter: DonationGlobalRankPresenter?
    
    private let accountId: String
    private let loader: DonationGlobalRankLoader
    private let selfRankLoader: DonationGlobalSelfRankLoader
    
    init(
        accountId: String,
        loader: DonationGlobalRankLoader,
        selfRankLoader: DonationGlobalSelfRankLoader
    ) {
        self.accountId = accountId
        self.loader = loader
        self.selfRankLoader = selfRankLoader
    }
    
    func loadDonationGlobalSelfRank() {
        selfRankLoader.loadSelfRank(accountId: accountId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishHeaderLoading(with: item)
            case .failure: break
            }
        }
    }
}

extension DonationGlobalRankPresentationAdapter: DonationGlobalRankLoaderControllerDelegate {
    func didRequestLoad() {
        presenter?.didStartLoading()
        loadDonationGlobalRank(page: 0)
    }
}

private extension DonationGlobalRankPresentationAdapter {
    func loadDonationGlobalRank(page: Int) {
        loader.load(.init(page: page)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(items):
                self.presenter?.didFinishLoading(with: items)
                
            case .failure:
                self.presenter?.didFinishLoading(with: [])
            }
        }
    }
}
