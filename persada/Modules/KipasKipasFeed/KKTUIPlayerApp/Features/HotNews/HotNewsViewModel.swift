//
//  HotNewsViewModel.swift
//  KKTUIPlayerApp
//
//  Created by DENAZMI on 24/09/23.
//

import Foundation

protocol IHotNewsViewModel {
    var page: Int { get set }
    
    func requestFeeds()
}

protocol HotNewsViewModelDelegate: AnyObject {
    func displayErrorGetFeeds(with message: String)
    func displayFeeds(with items: [FeedItem])
}

class HotNewsViewModel: IHotNewsViewModel {
    
    weak var delegate: HotNewsViewModelDelegate?
    let loader: FeedLoader
    var page: Int = 0
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func requestFeeds() {
        
        let request = PagedFeedLoaderRequest(page: page)
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .failure(let error):
                    self.delegate?.displayErrorGetFeeds(with: error.localizedDescription)
                case .success(let response):
                let items = response.data?.content?.toFeedItem()
                    self.delegate?.displayFeeds(with: items ?? [])
            }
        }
    }
}


private extension Array where Element == RemoteFeedContent {
    func toFeedItem() -> [FeedItem] {
        return compactMap({ content in
            
            let post = content.post.map({
                FeedPost(description: $0.descriptionValue)
            })
            
            let account = content.account.map({
                FeedAccount(username: $0.username)
            })
            
            let item = FeedItem(
                id: content.id,
                likes: content.likes,
                isLike: content.isLike,
                account: account,
                post: post
            )
            
            let media = content.post?.medias?.first
            item.coverPictureUrl = media?.thumbnail?.large ?? ""
            item.videoUrl = media?.playURL ?? ""
            item.duration = "\(media?.metadata?.duration ?? 0)"
            
            return item
        })
    }
}
