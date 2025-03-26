import Foundation

public final class NotificationFollowersService: NotificationFollowersControllerDelegate {
    
    public let loader: NotificationFollowersLoader
    public var presenter: NotificationFollowersPresenter?
    
    public init(loader: NotificationFollowersLoader) {
        self.loader = loader
    }
    
    public func didRequestFollowers(request: NotificationFollowersRequest) {
        presenter?.didStartLoadingGetNotificationFollowers()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetNotificationFollowers(with: item)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetNotificationFollowers(with: error)
            }
        }
    }
}
