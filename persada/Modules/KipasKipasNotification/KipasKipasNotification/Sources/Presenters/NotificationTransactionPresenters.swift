import Foundation

public class NotificationTransactionPresenter {
    
    private let successView: NotificationTransactionView?
    private let loadingView: NotificationTransactionLoadingView?
    private let errorView: NotificationTransactionLoadingErrorView?
    
    public init(
        successView: NotificationTransactionView,
        loadingView: NotificationTransactionLoadingView,
        errorView: NotificationTransactionLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
        }
    
    public func didStartLoadingGetNotificationTransaction() {
        errorView?.display(.noError)
        loadingView?.display(NotificationTransactionLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingGetNotificationTransaction(with items: NotificationTransactionContent) {
        successView?.display(NotificationTransactionViewModel(items: items))
        loadingView?.display(NotificationTransactionLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingGetNotificationTransaction(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(NotificationTransactionLoadingViewModel(isLoading: false))
    }
}

public protocol NotificationTransactionView {
    func display(_ viewModel: NotificationTransactionViewModel)
}

public protocol NotificationTransactionLoadingView {
    func display(_ viewModel: NotificationTransactionLoadingViewModel)
}

public protocol NotificationTransactionLoadingErrorView {
    func display(_ viewModel: NotificationTransactionLoadingErrorViewModel)
}


public struct NotificationTransactionViewModel {
    public let items: NotificationTransactionContent
}

public struct NotificationTransactionLoadingViewModel {
    public let isLoading: Bool
}

public struct NotificationTransactionLoadingErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationTransactionLoadingErrorViewModel {
        return NotificationTransactionLoadingErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationTransactionLoadingErrorViewModel {
        return NotificationTransactionLoadingErrorViewModel(message: message)
    }
}

