import Foundation
import KipasKipasStory

public class NotificationStoryPresenter {
    
    private let successView: NotificationStoryView?
    private let loadingView: NotificationStoryLoadingView?
    private let errorView: NotificationStoryLoadingErrorView?
    
    init(
        successView: NotificationStoryView,
        loadingView: NotificationStoryLoadingView,
        errorView: NotificationStoryLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
        }
    
    func didStartLoadingGetNotificationStory() {
        errorView?.display(.noError)
        loadingView?.display(NotificationStoryLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetNotificationStory(with data: StoryData) {
        successView?.display(NotificationStoryViewModel(data: data))
        loadingView?.display(NotificationStoryLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetNotificationStory(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(NotificationStoryLoadingViewModel(isLoading: false))
    }
}

protocol NotificationStoryView {
    func display(_ viewModel: NotificationStoryViewModel)
}

protocol NotificationStoryLoadingView {
    func display(_ viewModel: NotificationStoryLoadingViewModel)
}

protocol NotificationStoryLoadingErrorView {
    func display(_ viewModel: NotificationStoryLoadingErrorViewModel)
}


struct NotificationStoryViewModel {
    let data: StoryData
}

struct NotificationStoryLoadingViewModel {
    let isLoading: Bool
}

struct NotificationStoryLoadingErrorViewModel {
    let message: String?
    
    static var noError: NotificationStoryLoadingErrorViewModel {
        return NotificationStoryLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> NotificationStoryLoadingErrorViewModel {
        return NotificationStoryLoadingErrorViewModel(message: message)
    }
}

