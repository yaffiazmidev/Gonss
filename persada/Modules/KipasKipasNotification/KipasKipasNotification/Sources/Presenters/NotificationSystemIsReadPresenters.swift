import Foundation

public class NotificationSystemIsReadPresenter {
    
    private let successView: NotificationSystemIsReadView?
    private let errorView: NotificationSystemIsReadErrorLoadingView?
    
    public init(successView: NotificationSystemIsReadView, errorView: NotificationSystemIsReadErrorLoadingView) {
        self.successView = successView
        self.errorView = errorView
    }
    
    public func didStartLoading() {
        errorView?.display(.noError)
    }
    
    public func didFinishLoading(with item: NotificationDefaultResponse) {
        successView?.display(.init(status: item))
    }
    
    public func didFinishLoading(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
    }
}

public protocol NotificationSystemIsReadView {
    func display(_ viewModel: NotificationSystemIsReadViewModel)
}

public protocol NotificationSystemIsReadErrorLoadingView {
    func display(_ viewModel: NotificationSystemIsReadErrorViewModel)
}

public struct NotificationSystemIsReadViewModel {
    public let status: NotificationDefaultResponse
}

public struct NotificationSystemIsReadErrorViewModel {
    public let message: String?
    
    public static var noError: NotificationSystemIsReadErrorViewModel {
        return NotificationSystemIsReadErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> NotificationSystemIsReadErrorViewModel {
        return NotificationSystemIsReadErrorViewModel(message: message)
    }
}
