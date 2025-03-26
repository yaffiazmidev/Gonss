import UIKit
import KipasKipasShared
import KipasKipasDonationBadge

public enum ListBadgeUIComposer {
    
    public static func composeListBadgeWith(
        loader: ListBadgeLoader
    ) -> ListBadgeViewController {
        
        let adapter = ListBadgePresentationAdapter(
            listBadgeLoader: MainQueueDispatchDecorator(decoratee: loader)
        )
        
        let viewController = ListBadgeViewController()
        viewController.onLoad = adapter.load
        viewController.onUpdate = adapter.updateBadge(isShowBadge:)
        
        adapter.presenter = ListBadgePresenter(
            view: WeakRefVirtualProxy(viewController),
            loadingView: WeakRefVirtualProxy(viewController)
        )
        
        return viewController
    }
}

extension MainQueueDispatchDecorator: ListBadgeLoader where T == ListBadgeLoader {
    public func updateBadge(isShowBadge: Bool, completion: @escaping (Error?) -> Void) {
        decoratee.updateBadge(isShowBadge: isShowBadge) { [weak self] error in
            self?.dispatch { completion(error) }
        }
    }
    
    public func loadBadge(completion: @escaping (ListBadgeLoader.Result) -> Void) {
        decoratee.loadBadge { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension WeakRefVirtualProxy: ListBadgeView where T: ListBadgeView {
    public func display(_ viewModel: ListBadgeViewModel) {
        object?.display(viewModel)
    }
    
    public func display(_ isUpdateSuccess: Bool) {
        object?.display(isUpdateSuccess)
    }
}

extension WeakRefVirtualProxy: ListBadgeLoadingView where T: ListBadgeLoadingView {
    public func display(_ viewModel: ListBadgeLoadingViewModel) {
        object?.display(viewModel)
    }
}
