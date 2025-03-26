import UIKit
import KipasKipasDonationHistory
import KipasKipasShared

final class DonationHistoryViewAdapter {
    
    private weak var controller: DonationHistoryViewController?
    
    init(controller: DonationHistoryViewController) {
        self.controller = controller
    }
}

extension DonationHistoryViewAdapter: DonationHistoryView {
    func display(_ viewModel: [DonationHistoryViewModel], isFirstLoad: Bool) {
        let controllers = viewModel.map {
            return DonationHistoryCellController(viewModel: $0)
        }
    
        if isFirstLoad {
            controller?.set(controllers)
        } else {
            controller?.append(controllers)
        }
    }
}
