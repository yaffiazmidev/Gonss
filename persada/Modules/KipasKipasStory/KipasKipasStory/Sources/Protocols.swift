import Foundation

// MARK: - List
public protocol StoryListInteractor {
    typealias StoryDataResult = Swift.Result<StoryData, Error>
    
    func load(
        _ param: StoryListRequest,
        completion: @escaping (StoryDataResult) -> Void
    )
}

// MARK: - Viewers
public protocol StoryViewersInteractor {
    typealias StoryViewersResult = Swift.Result<[StoryViewer], Error>
    
    func load(
        _ param: StoryViewerRequest,
        completion: @escaping (StoryViewersResult) -> Void
    )
}
