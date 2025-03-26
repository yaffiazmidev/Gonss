import Foundation

public class NotificationFollowersPresenter {
    
    private let successView: NotificationFollowersView?
    private let loadingView: NotificationFollowersLoadingView?
    private let errorView: NotificationFollowersLoadingErrorView?
    
    public init(
        successView: NotificationFollowersView,
        loadingView: NotificationFollowersLoadingView,
        errorView: NotificationFollowersLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
        }
    
    public func didStartLoadingGetNotificationFollowers() {
        errorView?.display(.noError)
        loadingView?.display(NotificationFollowersLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingGetNotificationFollowers(with  content: NotificationFollowersItem) {
        successView?.display(NotificationFollowersViewModel(content: content))
        loadingView?.display(NotificationFollowersLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingGetNotificationFollowers(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(NotificationFollowersLoadingViewModel(isLoading: false))
    }
}

public protocol NotificationFollowersView {
    func display(_ viewModel: NotificationFollowersViewModel)
}

public protocol NotificationFollowersLoadingView {
    func display(_ viewModel: NotificationFollowersLoadingViewModel)
}

public protocol NotificationFollowersLoadingErrorView {
    func display(_ viewModel: NotificationFollowersLoadingErrorViewModel)
}


public struct NotificationFollowersViewModel {
    public let content: NotificationFollowersItem
}

public struct NotificationFollowersLoadingViewModel {
    public let isLoading: Bool
}

public struct NotificationFollowersLoadingErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationFollowersLoadingErrorViewModel {
        return NotificationFollowersLoadingErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationFollowersLoadingErrorViewModel {
        return NotificationFollowersLoadingErrorViewModel(message: message)
    }
}

