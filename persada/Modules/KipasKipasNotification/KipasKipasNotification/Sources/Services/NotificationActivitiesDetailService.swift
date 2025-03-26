import Foundation

public final class NotificationActivitiesDetailService: NotificationActivitiesDetailControllerDelegate {
    
    public let loader: NotificationActivitiesDetailLoader
    public var presenter: NotificationActivitiesDetailPresenter?
    
    public init(loader: NotificationActivitiesDetailLoader) {
        self.loader = loader
    }
    
    public func didRequestActivitiesDetail(request: NotificationActivitiesDetailRequest) {
        presenter?.didStartLoadingGetNotificationActivitiesDetail()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetNotificationActivitiesDetail(with: item)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetNotificationActivitiesDetail(with: error)
            }
        }
    }
}
