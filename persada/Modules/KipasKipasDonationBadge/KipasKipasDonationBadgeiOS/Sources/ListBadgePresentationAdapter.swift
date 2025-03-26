import Foundation
import KipasKipasDonationBadge

final class ListBadgePresentationAdapter {
    
    private let listBadgeLoader: ListBadgeLoader
    
    var presenter: ListBadgePresenter?
    
    init(listBadgeLoader: ListBadgeLoader) {
        self.listBadgeLoader = listBadgeLoader
    }
    
    func load() {
        presenter?.didStartLoading()
        listBadgeLoader.loadBadge { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(badges):
                self.presenter?.didFinishLoad(with: badges)
                
            case .failure:
                self.presenter?.didFinishLoad(with: [])
            }
        }
    }
    
    func updateBadge(isShowBadge: Bool) {
        listBadgeLoader.updateBadge(
            isShowBadge: isShowBadge
        ) { [weak self] in
            self?.presenter?.didFinishUpdateBadge(with: $0)
        }
    }
}
