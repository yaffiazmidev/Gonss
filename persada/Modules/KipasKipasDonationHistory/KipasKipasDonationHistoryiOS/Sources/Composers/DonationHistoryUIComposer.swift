import UIKit
import KipasKipasDonationHistory
import KipasKipasNetworking
import KipasKipasShared

public enum DonationHistoryUIComposer {
    
    public static func composeDonationHistoryWith(
        type: String,
        campaignId: String,
        emptyMessage: String,
        loader: DonationHistoryLoader
    ) -> DonationHistoryViewController {
        
        let adapter = DonationHistoryPresentationAdapter(
            type: type,
            campaignId: campaignId,
            loader: MainQueueDispatchDecorator(decoratee: loader)
        )
        
        let pagingController = DonationHistoryPagingController(delegate: adapter)
        let viewController = DonationHistoryViewController(pagingController: pagingController, emptyMessage: emptyMessage)
        
        adapter.presenter = DonationHistoryPresenter(
            view: DonationHistoryViewAdapter(controller: viewController),
            loadingView: WeakRefVirtualProxy(viewController),
            pagingView: WeakRefVirtualProxy(pagingController)
        )
        
        viewController.onLoad = adapter.load
        
        return viewController
    }
}

extension MainQueueDispatchDecorator: DonationHistoryLoader where T == DonationHistoryLoader {
    public func load(request: DonationHistoryRequest, completion: @escaping (DonationHistoryLoader.Result) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension WeakRefVirtualProxy: DonationHistoryPagingView where T: DonationHistoryPagingView {
    public func display(_ viewModel: DonationHistoryPagingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: DonationHistoryView where T: DonationHistoryView {
    public func display(_ viewModel: [DonationHistoryViewModel], isFirstLoad: Bool) {
        object?.display(viewModel, isFirstLoad: isFirstLoad)
    }
}

extension WeakRefVirtualProxy: DonationHistoryLoadingView where T: DonationHistoryLoadingView {
    public func display(_ viewModel: DonationHistoryLoadingViewModel) {
        object?.display(viewModel)
    }
}
