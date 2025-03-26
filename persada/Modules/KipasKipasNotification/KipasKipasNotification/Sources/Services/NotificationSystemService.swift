import Foundation

public final class NotificationSystemService: NotificationSystemControllerDelegate {
    
    public let loader: NotificationSystemLoader
    public var presenter: NotificationSystemPresenter?
    public var presenterIsRead: NotificationSystemIsReadPresenter?
    public var presenterUnread: NotificationSystemUnreadPresenter?
    
    public init(loader: NotificationSystemLoader) {
        self.loader = loader
    }
    
    public func load(page: Int = 0, size: Int, types: String = "all") {
        didRequestSystems(request: NotificationSystemRequest(page: page, size: size, types: types))
    }
    
    public func unread(isRead: Bool = true, types: String = "account"){
        didRequestSystemUnread(request: NotificationSystemUnreadRequest(isRead: isRead), types: types)
    }
    
    public func didRequestSystems(request: NotificationSystemRequest) {
        presenter?.didStartLoading()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoading(with: [item], isFirstLoad: request.page == 0)
            case .failure:
                self.presenter?.didFinishLoading(with: [], isFirstLoad: request.page == 0)
            }
        }
    }
    
    public func didRequestSystemUnread(request: NotificationSystemUnreadRequest, types: String) {
        presenterUnread?.didStartLoading()
        loader.unread(request: request, types: types) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenterUnread?.didFinishLoading(with: item)
            case let .failure(error):
                self.presenterUnread?.didFinishLoading(with: error)
            }
        }
    }
    
    public func didRequestSystemIsRead(request: NotificationSystemIsReadRequest, types: String) {
        presenterIsRead?.didStartLoading()
        
        loader.read(request: request, types: types) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenterIsRead?.didFinishLoading(with: item)
            case let .failure(error):
                self.presenterIsRead?.didFinishLoading(with: error)
            }
        }
    }
}
