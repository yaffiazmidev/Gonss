import Foundation

public class NotificationSystemUnreadPresenter {
    
    private let successView: NotificationSystemUnreadView?
    private let errorView: NotificationSystemUnreadErrorLoadingView?
    
    public init(successView: NotificationSystemUnreadView, errorView: NotificationSystemUnreadErrorLoadingView) {
        self.successView = successView
        self.errorView = errorView
    }
    
    public func didStartLoading() {
        errorView?.display(.noError)
    }
    
    public func didFinishLoading(with item: NotificationSystemUnreadItem) {
        successView?.display(.init(status: item.data.hasUnreadNotifications))
    }
    
    public func didFinishLoading(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
    }
}

public protocol NotificationSystemUnreadView {
    func display(_ viewModel: NotificationSystemUnreadViewModel)
}

public protocol NotificationSystemUnreadErrorLoadingView {
    func display(_ viewModel: NotificationSystemUnreadErrorViewModel)
}

public struct NotificationSystemUnreadViewModel {
    public let status: Bool
}

public struct NotificationSystemUnreadErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationSystemUnreadErrorViewModel {
        return NotificationSystemUnreadErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationSystemUnreadErrorViewModel {
        return NotificationSystemUnreadErrorViewModel(message: message)
    }
}
