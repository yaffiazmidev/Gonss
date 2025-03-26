import Foundation

public class NotificationActivitiesDetailPresenter {
    
    private let successView: NotificationActivitiesDetailView?
    private let loadingView: NotificationActivitiesDetailLoadingView?
    private let errorView: NotificationActivitiesDetailLoadingErrorView?
    
    public init(
        successView: NotificationActivitiesDetailView,
        loadingView: NotificationActivitiesDetailLoadingView,
        errorView: NotificationActivitiesDetailLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
        }
    
    public func didStartLoadingGetNotificationActivitiesDetail() {
        errorView?.display(.noError)
        loadingView?.display(NotificationActivitiesDetailLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingGetNotificationActivitiesDetail(with items: NotificationSuggestionAccountContent) {
        successView?.display(NotificationActivitiesDetailViewModel(items: items))
        loadingView?.display(NotificationActivitiesDetailLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingGetNotificationActivitiesDetail(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(NotificationActivitiesDetailLoadingViewModel(isLoading: false))
    }
}

public protocol NotificationActivitiesDetailView {
    func display(_ viewModel: NotificationActivitiesDetailViewModel)
}

public protocol NotificationActivitiesDetailLoadingView {
    func display(_ viewModel: NotificationActivitiesDetailLoadingViewModel)
}

public protocol NotificationActivitiesDetailLoadingErrorView {
    func display(_ viewModel: NotificationActivitiesDetailLoadingErrorViewModel)
}


public struct NotificationActivitiesDetailViewModel {
    public let items: NotificationSuggestionAccountContent
}

public struct NotificationActivitiesDetailLoadingViewModel {
    public let isLoading: Bool
}

public struct NotificationActivitiesDetailLoadingErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationActivitiesDetailLoadingErrorViewModel {
        return NotificationActivitiesDetailLoadingErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationActivitiesDetailLoadingErrorViewModel {
        return NotificationActivitiesDetailLoadingErrorViewModel(message: message)
    }
}

