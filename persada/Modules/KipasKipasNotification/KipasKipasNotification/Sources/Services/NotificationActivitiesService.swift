import Foundation

public final class NotificationActivitiesService: NotificationActivitiesControllerDelegate {
    
    public let loader: NotificationActivitiesLoader
    public var presenter: NotificationActivitiesPresenter?
    
    public init(loader: NotificationActivitiesLoader) {
        self.loader = loader
    }
    
    public func didRequestActivities(request: NotificationActivitiesRequest) {
        presenter?.didStartLoadingGetNotificationActivities()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetNotificationActivities(with: item)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetNotificationActivities(with: error)
            }
        }
    }
}
