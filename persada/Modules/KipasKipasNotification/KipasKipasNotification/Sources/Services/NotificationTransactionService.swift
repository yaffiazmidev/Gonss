import Foundation

public final class NotificationTransactionService: NotificationTransactionControllerDelegate {
    
    public let loader: NotificationTransactionLoader
    public var presenter: NotificationTransactionPresenter?
    
    public init(loader: NotificationTransactionLoader) {
        self.loader = loader
    }
    
    public func didRequestTransaction(request: NotificationTransactionRequest) {
        presenter?.didStartLoadingGetNotificationTransaction()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetNotificationTransaction(with: item)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetNotificationTransaction(with: error)
            }
        }
    }
}
