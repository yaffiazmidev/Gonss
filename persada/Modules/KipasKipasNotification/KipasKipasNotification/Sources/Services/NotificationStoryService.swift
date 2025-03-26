import Foundation
import KipasKipasStory

public final class NotificationStoryService: NotificationStoryControllerDelegate {
    
    public let loader: StoryListInteractor
    public var presenter: NotificationStoryPresenter?
    
    public init(loader: StoryListInteractor) {
        self.loader = loader
    }
    
    public func didRequestStory(request: StoryListRequest) {
        presenter?.didStartLoadingGetNotificationStory()
        loader.load(request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(stories):
                self.presenter?.didFinishLoadingGetNotificationStory(with: stories)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetNotificationStory(with: error)
            }
        }
    }
}
