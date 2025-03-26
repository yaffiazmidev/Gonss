import Foundation

public final class NotificationFollowUserService: NotificationFollowUserControllerDelegate {
    
    public let loader: NotificationFollowUserLoader
    public var presenter: NotificationFollowUserPresenter?
    
    public init(loader: NotificationFollowUserLoader) {
        self.loader = loader
    }
    
    public func didRequestFollowUser(request: NotificationFollowUserRequest) {
        presenter?.didStartLoadingGetNotificationFollowUser()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.presenter?.didFinishLoadingGetNotificationFollowUser()
            case let .failure(error):
                self.presenter?.didFinishLoadingGetNotificationFollowUser(with: error)
            }
        }
    }
}
