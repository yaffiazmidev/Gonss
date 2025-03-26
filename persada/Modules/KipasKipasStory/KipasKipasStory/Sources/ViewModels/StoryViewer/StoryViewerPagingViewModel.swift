import Foundation

public struct StoryViewerPagingViewModel {
    public let viewers: [StoryViewerViewModel]
    public let page: Int
    public let totalPages: Int
    public let isFirstPage: Bool
    public let isLastPage: Bool
    
    
    public init(
        viewers: [StoryViewerViewModel],
        page: Int,
        totalPages: Int,
        isFirstPage: Bool,
        isLastPage: Bool
    ) {
        self.viewers = viewers
        self.page = page
        self.totalPages = totalPages
        self.isFirstPage = isFirstPage
        self.isLastPage = isLastPage
    }
}
