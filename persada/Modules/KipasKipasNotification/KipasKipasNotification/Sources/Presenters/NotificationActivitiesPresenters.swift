import Foundation

public class NotificationActivitiesPresenter {
    
    private let successView: NotificationActivitiesView?
    private let loadingView: NotificationActivitiesLoadingView?
    private let errorView: NotificationActivitiesLoadingErrorView?
    
    public init(
        successView: NotificationActivitiesView,
        loadingView: NotificationActivitiesLoadingView,
        errorView: NotificationActivitiesLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
        }
    
    public func didStartLoadingGetNotificationActivities() {
        errorView?.display(.noError)
        loadingView?.display(NotificationActivitiesLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingGetNotificationActivities(with content: NotificationActivitiesContent) {
        successView?.display(NotificationActivitiesViewModel(content: content))
        loadingView?.display(NotificationActivitiesLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingGetNotificationActivities(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(NotificationActivitiesLoadingViewModel(isLoading: false))
    }
}

public protocol NotificationActivitiesView {
    func display(_ viewModel: NotificationActivitiesViewModel)
}

public protocol NotificationActivitiesLoadingView {
    func display(_ viewModel: NotificationActivitiesLoadingViewModel)
}

public protocol NotificationActivitiesLoadingErrorView {
    func display(_ viewModel: NotificationActivitiesLoadingErrorViewModel)
}


public struct NotificationActivitiesViewModel {
    public let content: NotificationActivitiesContent
}

public struct NotificationActivitiesLoadingViewModel {
    public let isLoading: Bool
}

public struct NotificationActivitiesLoadingErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationActivitiesLoadingErrorViewModel {
        return NotificationActivitiesLoadingErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationActivitiesLoadingErrorViewModel {
        return NotificationActivitiesLoadingErrorViewModel(message: message)
    }
}

