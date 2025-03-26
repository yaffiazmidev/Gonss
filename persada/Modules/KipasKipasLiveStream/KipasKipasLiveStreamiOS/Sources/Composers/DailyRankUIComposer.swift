import UIKit
import Combine
import KipasKipasLiveStream
import KipasKipasShared

public enum DailyRankUIComposer {
    
    public static func composeAudienceListUIWith(
        isAnchor:Bool,
        selectNavLeft:Bool,
        loader: @escaping () -> DailyRankLoader,
        popularLiveLoader: @escaping () -> DailyRankLoader,
        selection: @escaping (String) -> Void,
        sendGiftAction: @escaping () -> Void
    ) -> UIViewController {
        
        let adapter = LiveDailyRankPresentationAdapter(loader: loader,popularLiveLoader:popularLiveLoader)
        let controller = LiveDailyRankingViewController()
        
        adapter.presenter = LiveDailyRankPresenter(
            view: LiveDailyRankViewAdapter(
                controller: controller,
                selection: selection
            )
        )
        controller.isAnchor = isAnchor
        controller.selectNavLeft = selectNavLeft
        controller.onLoadDailyRank = adapter.loadDailyRank
        controller.onLoadPopularLive = adapter.loadPopularLive
        controller.sendGiftAction = sendGiftAction
        return controller
    }
}

extension WeakRefVirtualProxy: LiveDailyRankView where T: LiveDailyRankView {
    public func display(_ viewModel: [LiveDailyRankViewModel]) {
        object?.display(viewModel)
    }
    
    public func displayPopularLive(_ viewModel: [LiveDailyRankViewModel]) {
        object?.displayPopularLive(viewModel)
    }
}

