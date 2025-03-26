import Foundation

public class NotificationFollowUserPresenter {
    
    private let successView: NotificationFollowUserView?
    private let errorView: NotificationFollowUserLoadingErrorView?
    
    public init(
        successView: NotificationFollowUserView,
        errorView: NotificationFollowUserLoadingErrorView) {
            self.successView = successView
            self.errorView = errorView
        }
    
    public func didStartLoadingGetNotificationFollowUser() {
        errorView?.display(.noError)
    }
    
    public func didFinishLoadingGetNotificationFollowUser() {
        successView?.display(NotificationFollowUserViewModel(item: ()))
    }
    
    public func didFinishLoadingGetNotificationFollowUser(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
    }
}

public protocol NotificationFollowUserView {
    func display(_ viewModel: NotificationFollowUserViewModel)
}

public protocol NotificationFollowUserLoadingErrorView {
    func display(_ viewModel: NotificationFollowUserLoadingErrorViewModel)
}

public struct NotificationFollowUserViewModel {
    public let item: Void
}

public struct NotificationFollowUserLoadingErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationFollowUserLoadingErrorViewModel {
        return NotificationFollowUserLoadingErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationFollowUserLoadingErrorViewModel {
        return NotificationFollowUserLoadingErrorViewModel(message: message)
    }
}

