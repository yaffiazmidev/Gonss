import UIKit
import KipasKipasNotification
import KipasKipasNetworking
import KipasKipasShared

public final class NotificationSystemContentUIComposer {
    
    private init() {}
    
    public static func composeNotificationSystemWith(
        types: String,
        emptyMessage: String,
        loader: NotificationSystemLoader,
        showFeed: @escaping (String) -> Void
    ) -> UIViewController {
       
        let service = NotificationSystemService(loader: MainQueueDispatchDecorator(decoratee: loader))
        let pagingController = NotificationSystemPagingController(delegate: service)
        let viewController = NotificationSystemContentController(types: types, pagingController: pagingController, emptyMessage: emptyMessage)
        let viewAdapter = NotificationSystemContentViewService(controller: viewController, service: service, selection: showFeed)
        
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
        
        return viewController
    }
}
