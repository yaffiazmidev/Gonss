import UIKit
import KipasKipasDonationHistory

protocol DonationHistoryPagingControllerDelegate {
    func didRequestPage(page: Int)
}

final class DonationHistoryPagingController {
    
    private let delegate: DonationHistoryPagingControllerDelegate
    private var viewModel: DonationHistoryPagingViewModel?
    
    init(delegate: DonationHistoryPagingControllerDelegate) {
        self.delegate = delegate
    }
    
    func load() {
        guard let viewModel = viewModel,
                    let nextPage = viewModel.nextPage,
                    !viewModel.isLoading else {
            return
        }
        
        delegate.didRequestPage(page: nextPage)
    }
}

extension DonationHistoryPagingController: DonationHistoryPagingView {
    func display(_ viewModel: DonationHistoryPagingViewModel) {
        self.viewModel = viewModel
    }
}

