import Foundation

public final class NotificationActivitiesIsReadService: NotificationActivitiesIsReadControllerDelegate {
    
    public let checker: NotificationActivitiesIsReadCheck
    public var presenter: NotificationActivitiesIsReadPresenter?
    
    public init(checker: NotificationActivitiesIsReadCheck) {
        self.checker = checker
    }
    
    public func didRequestActivitiesIsRead(request: NotificationActivitiesIsReadRequest) {
        presenter?.didStartLoadingGetNotificationActivitiesIsRead()
        checker.check(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetNotificationActivitiesIsRead(with: item)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetNotificationActivitiesIsRead(with: error)
            }
        }
    }
}
