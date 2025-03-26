import Foundation

public final class NotificationProfileStoryPresenter {
    
    private let successView: NotificationProfileStoryView?
    private let loadingView: NotificationProfileStoryLoadingView?
    private let errorView: NotificationProfileStoryLoadingErrorView?
    
    public init(
        successView: NotificationProfileStoryView,
        loadingView: NotificationProfileStoryLoadingView,
        errorView: NotificationProfileStoryLoadingErrorView
    ) {
        self.successView = successView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingGetNotificationProfileStory() {
        errorView?.display(.noError)
        loadingView?.display(NotificationProfileStoryLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingGetNotificationProfileStory(with item: StoryProfileItem) {
        successView?.display(NotificationProfileStoryViewModel(item: item))
        loadingView?.display(NotificationProfileStoryLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingGetNotificationProfileStory(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(NotificationProfileStoryLoadingViewModel(isLoading: false))
    }
}

public protocol NotificationProfileStoryView {
    func display(_ viewModel: NotificationProfileStoryViewModel)
}

public protocol NotificationProfileStoryLoadingView {
    func display(_ viewModel: NotificationProfileStoryLoadingViewModel)
}

public protocol NotificationProfileStoryLoadingErrorView {
    func display(_ viewModel: NotificationProfileStoryLoadingErrorViewModel)
}


public struct NotificationProfileStoryViewModel {
    public let item: StoryProfileItem
}

public struct NotificationProfileStoryLoadingViewModel {
    public let isLoading: Bool
}

public struct NotificationProfileStoryLoadingErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationProfileStoryLoadingErrorViewModel {
        return NotificationProfileStoryLoadingErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationProfileStoryLoadingErrorViewModel {
        return NotificationProfileStoryLoadingErrorViewModel(message: message)
    }
}

