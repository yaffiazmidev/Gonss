import Foundation
import KipasKipasDonationHistory

final class DonationHistoryPresentationAdapter {
    
    private let type: String
    private let campaignId: String
    private let loader: DonationHistoryLoader
    
    var presenter: DonationHistoryPresenter?
    
    init(type: String, campaignId: String, loader: DonationHistoryLoader) {
        self.type = type
        self.campaignId = campaignId
        self.loader = loader
    }
    
    func load() {
        loadHistory(page: 0)
    }
    
    private func loadHistory(page: Int = 0) {
        loader.load(request: .init(
            page: page,
            type: type,
            campaignId: campaignId
        )) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(root):
                self.presenter?.didFinishLoad(with: root.data, isFirstLoad: page == 0)
                
            case .failure:
                self.presenter?.didFinishLoad(with: [], isFirstLoad: page == 0)
            }
        }
    }
}

extension DonationHistoryPresentationAdapter: DonationHistoryPagingControllerDelegate {
    func didRequestPage(page: Int) {
        loadHistory(page: page)
    }
}
