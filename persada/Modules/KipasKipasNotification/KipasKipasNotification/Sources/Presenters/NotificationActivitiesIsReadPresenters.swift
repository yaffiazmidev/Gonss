import Foundation

public class NotificationActivitiesIsReadPresenter {
    
    private let successView: NotificationActivitiesIsReadView?
    private let errorView: NotificationActivitiesIsReadLoadingErrorView?
    
    public init(
        successView: NotificationActivitiesIsReadView,
        errorView: NotificationActivitiesIsReadLoadingErrorView) {
            self.successView = successView
            self.errorView = errorView
        }
    
    public func didStartLoadingGetNotificationActivitiesIsRead() {
        errorView?.display(.noError)
    }
    
    public func didFinishLoadingGetNotificationActivitiesIsRead(with item: NotificationDefaultResponse) {
        successView?.display(NotificationActivitiesIsReadViewModel(item: item))
    }
    
    public func didFinishLoadingGetNotificationActivitiesIsRead(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
    }
}

public protocol NotificationActivitiesIsReadView {
    func display(_ viewModel: NotificationActivitiesIsReadViewModel)
}

public protocol NotificationActivitiesIsReadLoadingErrorView {
    func display(_ viewModel: NotificationActivitiesIsReadLoadingErrorViewModel)
}


public struct NotificationActivitiesIsReadViewModel {
    public let item: NotificationDefaultResponse
}


public struct NotificationActivitiesIsReadLoadingErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationActivitiesIsReadLoadingErrorViewModel {
        return NotificationActivitiesIsReadLoadingErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationActivitiesIsReadLoadingErrorViewModel {
        return NotificationActivitiesIsReadLoadingErrorViewModel(message: message)
    }
}

