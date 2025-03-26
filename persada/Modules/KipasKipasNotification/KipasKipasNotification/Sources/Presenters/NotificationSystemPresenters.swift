import Foundation

public class NotificationSystemPresenter {
    
    private let successView: NotificationSystemView?
    private let loadingView: NotificationSystemLoadingView?
    private let pagingView: NotificationSystemPagingView?
    
    public init(successView: NotificationSystemView, loadingView: NotificationSystemLoadingView, pagingView: NotificationSystemPagingView) {
        self.successView = successView
        self.loadingView = loadingView
        self.pagingView = pagingView
    }
    
    public func didStartLoading() {
        loadingView?.display(.init(isLoading: true))
        pagingView?.display(.init(isLoading: true, totalItems: 0))
    }
    
    public func didFinishLoading(with items: [NotificationSystemItem], isFirstLoad: Bool) {
        loadingView?.display(.init(isLoading: false))
        pagingView?.display(.init(isLoading: false, totalItems: items.count))
        successView?.display(.init(items: items), isFirstLoad: isFirstLoad)
    }
    
}

public protocol NotificationSystemView {
    func display(_ viewModel: NotificationSystemViewModel, isFirstLoad: Bool)
}

public protocol NotificationSystemLoadingView {
    func display(_ viewModel: NotificationSystemLoadingViewModel)
}

public protocol NotificationSystemPagingView {
    func display(_ viewModel: NotificationSystemPagingViewModel)
}

public struct NotificationSystemViewModel {
    public let items: [NotificationSystemItem]
}

public struct NotificationSystemLoadingViewModel {
    public let isLoading: Bool
}

public struct NotificationSystemPagingViewModel: Equatable {
    public let isLoading: Bool
    public let totalItems: Int
    
    public var size: Int {
        return 10
    }
    
    public var currentPage: Int {
        let page = round(Double(totalItems) / Double(size))
        let currentPage = Int(page) - 1
        return currentPage
    }
    
    public var isLast: Bool {
        return totalItems < size
    }
    
    public var nextPage: Int? {
        return isLast ? nil : currentPage + 1
    }
    
    public init(isLoading: Bool, totalItems: Int) {
        self.isLoading = isLoading
        self.totalItems = totalItems
    }
}
