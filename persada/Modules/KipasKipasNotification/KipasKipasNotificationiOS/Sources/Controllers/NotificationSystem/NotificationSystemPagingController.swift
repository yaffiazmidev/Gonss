import Foundation
import KipasKipasNotification
import UIKit

public protocol NotificationSystemPagingControllerDelegate {
    func didRequestPage(page: Int)
}

public class NotificationSystemPagingController {
    
    private let delegate: NotificationSystemControllerDelegate?
    private var viewModel: NotificationSystemPagingViewModel?
    
    public init(delegate: NotificationSystemControllerDelegate) {
        self.delegate = delegate
    }
    
    public func load(types: String = "all") {
        guard let viewModel = viewModel,
              let nextPage = viewModel.nextPage,
              !viewModel.isLoading else {
            return
        }
        
        delegate?.didRequestSystems(request: NotificationSystemRequest(page: nextPage, size: 10, types: types))
    }
}

extension NotificationSystemPagingController: NotificationSystemPagingView {
    public func display(_ viewModel: NotificationSystemPagingViewModel) {
        self.viewModel = viewModel
    }
}
