import UIKit
import KipasKipasNotification
import KipasKipasNetworking
import KipasKipasShared

public final class NotificationSystemUIComposer {
    
    private init() {}
    
    public struct EventsNotification {
        let showContent: (String) -> Void
        let showFeed: (String) -> Void
        
        public init(
            showContent: @escaping (String) -> Void,
            showFeed: @escaping (String) -> Void
        ) {
            self.showContent = showContent
            self.showFeed = showFeed
        }
    }
    
    public static func composeNotificationSystemWith(
        emptyMessage: String,
        loader: NotificationSystemLoader,
        events: EventsNotification
    ) -> UIViewController {
       
        let service = NotificationSystemService(loader: MainQueueDispatchDecorator(decoratee: loader))
        let pagingController = NotificationSystemPagingController(delegate: service)
        let viewController = NotificationSystemController(pagingController: pagingController, emptyMessage: emptyMessage, showContentTypes: events.showContent, showFeed: events.showFeed)
        let viewAdapter = NotificationSystemViewService(controller: viewController, service: service, selection: events.showFeed) 
        
        service.presenter = NotificationSystemPresenter(
            successView: viewAdapter,
            loadingView: WeakRefVirtualProxy(viewController),
            pagingView: WeakRefVirtualProxy(pagingController)
        )
        
        service.presenterIsRead = NotificationSystemIsReadPresenter(
            successView: viewAdapter,
            errorView: viewAdapter
        )
        
        service.presenterUnread = NotificationSystemUnreadPresenter(
            successView: WeakRefVirtualProxy(viewController),
            errorView: WeakRefVirtualProxy(viewController))
        
        viewController.onLoad = service.load
        viewController.unread = service.unread
        
        return viewController
    }
}

extension MainQueueDispatchDecorator: NotificationSystemLoader where T == NotificationSystemLoader {
    public func read(request: KipasKipasNotification.NotificationSystemIsReadRequest, types: String, completion: @escaping (ResultSystemIsRead) -> Void) {
        decoratee.read(request: request, types: types) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    public func unread(request: KipasKipasNotification.NotificationSystemUnreadRequest, types: String, completion: @escaping (ResultSystemUnread) -> Void) {
        decoratee.unread(request: request, types: types) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    public func load(request: NotificationSystemRequest, completion: @escaping (ResultSystem) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension WeakRefVirtualProxy: NotificationSystemPagingView where T: NotificationSystemPagingView {
    public func display(_ viewModel: NotificationSystemPagingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: NotificationSystemView where T: NotificationSystemView {
    public func display(_ viewModel: NotificationSystemViewModel, isFirstLoad: Bool) {
        object?.display(viewModel, isFirstLoad: isFirstLoad)
    }
}

extension WeakRefVirtualProxy: NotificationSystemLoadingView where T: NotificationSystemLoadingView {
    public func display(_ viewModel: NotificationSystemLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: NotificationSystemIsReadView where T: NotificationSystemIsReadView {
    public func display(_ viewModel: KipasKipasNotification.NotificationSystemIsReadViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: NotificationSystemIsReadErrorLoadingView where T: NotificationSystemIsReadErrorLoadingView {
    public func display(_ viewModel: NotificationSystemIsReadErrorViewModel ){
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: NotificationSystemUnreadView where T: NotificationSystemUnreadView {
    public func display(_ viewModel: KipasKipasNotification.NotificationSystemUnreadViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: NotificationSystemUnreadErrorLoadingView where T: NotificationSystemUnreadErrorLoadingView {
    public func display(_ viewModel: NotificationSystemUnreadErrorViewModel ){
        object?.display(viewModel)
    }
}
