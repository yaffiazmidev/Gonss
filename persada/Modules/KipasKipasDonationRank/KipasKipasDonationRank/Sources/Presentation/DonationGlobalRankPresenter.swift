import Foundation

public protocol DonationGlobalRankView {
    func display(_ viewModel: DonationGlobalRankViewModel)
}

public protocol DonationGlobalRankLoadingView {
    func display(_ viewModel: DonationGlobalRankLoadingViewModel)
}

public protocol DonationGlobalRankHeaderView {
    func display(_ viewModel: DonationGlobalRankHeaderViewModel)
}

public class DonationGlobalRankPresenter {
    
    private let view: DonationGlobalRankView
    private let loadingView: DonationGlobalRankLoadingView
    private let headerView: DonationGlobalRankHeaderView

    public init(
        view: DonationGlobalRankView,
        loadingView: DonationGlobalRankLoadingView,
        headerView: DonationGlobalRankHeaderView
    ) {
        self.view = view
        self.loadingView = loadingView
        self.headerView = headerView
    }
    
    public func didStartLoading() {
        loadingView.display(.init(isLoading: true))
    }
    
    public func didFinishLoading(with items: [DonationGlobalRankItem]) {
        loadingView.display(.init(isLoading: false))
        view.display(.init(items: items))
    }
   
    public func didFinishHeaderLoading(with item: DonationGlobalRankItem) {
        headerView.display(.init(item: item))
    }
}
