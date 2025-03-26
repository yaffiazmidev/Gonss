import Foundation
import FeedCleeps

final class FeedLoaderFilteredByBlockedUserDecorator: FeedCleeps.FeedCleepsLoader {
    
    private let blockedUserStore: BlockedUserStore
    private let loader: FeedCleeps.FeedCleepsLoader
    
    init(blockedUserStore: BlockedUserStore, loader: FeedCleeps.FeedCleepsLoader) {
        self.blockedUserStore = blockedUserStore
        self.loader = loader
    }
    
    func load(request: FeedCleeps.PagedFeedCleepsLoaderRequest, completion: @escaping (FeedCleeps.FeedCleepsLoader.Result) -> Void) {
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(feeds):
                var feeds = feeds
                var content = feeds.data?.content ?? []
                content.removeAll(where: {
                    guard let id = $0.account?.id else { return false }
                    return self.blockedUserStore.retrieve()?.contains(id) == true
                })
                feeds.data?.content = content
                completion(.success(feeds))
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func seen(request: SeenFeedCleepsRequest, completion: @escaping (SeenResult) -> Void) {
        loader.seen(request: request, completion: completion)
    }
}
