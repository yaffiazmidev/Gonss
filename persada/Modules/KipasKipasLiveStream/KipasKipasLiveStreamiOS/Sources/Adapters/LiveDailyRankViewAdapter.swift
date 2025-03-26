import UIKit
import KipasKipasLiveStream

final class LiveDailyRankViewAdapter {
    
    weak var controller: LiveDailyRankingViewController?
    private let selection: (String) -> Void
    
    init(
        controller: LiveDailyRankingViewController,
        selection: @escaping (String) -> Void
    ) {
        self.controller = controller
        self.selection = selection
    }
}

extension LiveDailyRankViewAdapter: LiveDailyRankView {
    func display(_ viewModels: [LiveDailyRankViewModel]) {
        
        controller?.selection =  { [controller, selection] userId in
            controller?.dismiss(animated: true) { selection(userId) }
        }
        
        controller?.setTopRanks(from: viewModels)
        controller?.setRegularRanks(from: viewModels)
    }
    
    func displayPopularLive(_ viewModels: [LiveDailyRankViewModel]) {
        
        controller?.selection =  { [controller, selection] userId in
            controller?.dismiss(animated: true) { selection(userId) }
        }
        
        controller?.setPopularTopRanks(from: viewModels)
        controller?.setPopularRegularRanks(from: viewModels)
    }
}
