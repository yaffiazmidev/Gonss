import UIKit
import KipasKipasDonationRank
import KipasKipasShared

public enum DonationGlobalRankUIComposer {
    
    public static func composeUIWith(
        accountId: String,
        loader: DonationGlobalRankLoader,
        selfRankLoader: DonationGlobalSelfRankLoader
    ) -> DonationGlobalRankViewController {
        
        let adapter = DonationGlobalRankPresentationAdapter(
            accountId: accountId,
            loader: MainQueueDispatchDecorator(decoratee: loader),
            selfRankLoader: MainQueueDispatchDecorator(decoratee: selfRankLoader)
        )
        
        let loadingController = DonationGlobalRankLoadingController(delegate: adapter)
        
        let viewController = DonationGlobalRankViewController(loadingController: loadingController)
        viewController.onRefreshHeader = adapter.loadDonationGlobalSelfRank
        
        adapter.presenter = DonationGlobalRankPresenter(
            view: DonationGlobalRankViewAdapter(controller: viewController),
            loadingView: WeakRefVirtualProxy(viewController),
            headerView: WeakRefVirtualProxy(viewController)
        )
        
        return viewController
    }
}

extension MainQueueDispatchDecorator: DonationGlobalRankLoader where T == DonationGlobalRankLoader {
    public func load(
        _ request: DonationGlobalRankRequest,
        completion: @escaping (DonationGlobalRankLoader.Result) -> Void
    ) {
        decoratee.load(request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: DonationGlobalSelfRankLoader where T == DonationGlobalSelfRankLoader {
    public func loadSelfRank(accountId: String, completion: @escaping (DonationGlobalSelfRankLoader.Result) -> Void) {
        decoratee.loadSelfRank(accountId: accountId) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension WeakRefVirtualProxy: DonationGlobalRankHeaderView where T: DonationGlobalRankHeaderView {
    public func display(_ viewModel: DonationGlobalRankHeaderViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: DonationGlobalRankLoadingView where T: DonationGlobalRankLoadingView {
    public func display(_ viewModel: DonationGlobalRankLoadingViewModel) {
        object?.display(viewModel)
    }
}
