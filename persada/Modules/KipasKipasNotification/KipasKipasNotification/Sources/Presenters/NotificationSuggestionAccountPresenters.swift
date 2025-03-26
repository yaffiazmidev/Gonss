import Foundation

public class NotificationSuggestionAccountPresenter {
    
    private let successView: NotificationSuggestionAccountView?
    private let loadingView: NotificationSuggestionAccountLoadingView?
    private let errorView: NotificationSuggestionAccountLoadingErrorView?
    
    public init(
        successView: NotificationSuggestionAccountView,
        loadingView: NotificationSuggestionAccountLoadingView,
        errorView: NotificationSuggestionAccountLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
        }
    
    public func didStartLoadingGetNotificationSuggestionAccount() {
        errorView?.display(.noError)
        loadingView?.display(NotificationSuggestionAccountLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingGetNotificationSuggestionAccount(with content: NotificationSuggestionAccountContent) {
        successView?.display(NotificationSuggestionAccountViewModel(items: content))
        loadingView?.display(NotificationSuggestionAccountLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingGetNotificationSuggestionAccount(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(NotificationSuggestionAccountLoadingViewModel(isLoading: false))
    }
}

public protocol NotificationSuggestionAccountView {
    func display(_ viewModel: NotificationSuggestionAccountViewModel)
}

public protocol NotificationSuggestionAccountLoadingView {
    func display(_ viewModel: NotificationSuggestionAccountLoadingViewModel)
}

public protocol NotificationSuggestionAccountLoadingErrorView {
    func display(_ viewModel: NotificationSuggestionAccountLoadingErrorViewModel)
}


public struct NotificationSuggestionAccountViewModel {
    public let items: NotificationSuggestionAccountContent
}

public struct NotificationSuggestionAccountLoadingViewModel {
    public let isLoading: Bool
}

public struct NotificationSuggestionAccountLoadingErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationSuggestionAccountLoadingErrorViewModel {
        return NotificationSuggestionAccountLoadingErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationSuggestionAccountLoadingErrorViewModel {
        return NotificationSuggestionAccountLoadingErrorViewModel(message: message)
    }
}

