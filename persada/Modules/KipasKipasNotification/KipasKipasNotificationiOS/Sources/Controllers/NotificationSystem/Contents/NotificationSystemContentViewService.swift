import UIKit
import KipasKipasNotification
import KipasKipasShared

final class NotificationSystemContentViewService {
    private weak var controller: NotificationSystemContentController?
    private let service: NotificationSystemService
    private let selection: (String) -> Void
    
    init(controller: NotificationSystemContentController?, service: NotificationSystemService, selection: @escaping (String) -> Void) {
        self.controller = controller
        self.service = service
        self.selection = selection
    }
}

extension NotificationSystemContentViewService: NotificationSystemView {
    func display(_ viewModel: NotificationSystemViewModel, isFirstLoad: Bool) {
        let adapter = NotificationSystemIsReadService(service: service)
        
        let controllers = viewModel.items.map {
            return NotificationSystemCellController(viewModel: $0, delegate: adapter, selection: selection)
        }
        
        if isFirstLoad {
            controller?.set(controllers)
        } else {
            controller?.append(controllers)
        }
    }
}

extension NotificationSystemContentViewService: NotificationSystemIsReadView, NotificationSystemIsReadErrorLoadingView {
    func display(_ viewModel: NotificationSystemIsReadViewModel) {
        if viewModel.status.code == "1000" {
            controller?.configureRequest()
        }
    }
   
    func display(_ viewModel: NotificationSystemIsReadErrorViewModel) {
        print("message \(viewModel.message ?? "error unknown")")
    }
}
