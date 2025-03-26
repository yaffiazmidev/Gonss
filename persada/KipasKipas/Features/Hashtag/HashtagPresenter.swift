//
//  HashtagPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import FeedCleeps

protocol IHashtagPresenter: AnyObject {
    func presentHashtags(with response: FeedArray?)
}

class HashtagPresenter: IHashtagPresenter {
    
    weak var controller: IHashtagViewController!
    var identifier: TiktokType?
    
    init(controller: IHashtagViewController) {
        self.controller = controller
    }
    
    func presentHashtags(with response: FeedArray?) {
        if let feeds = response?.data?.content {
            let hashtagItems = feeds.map({ feed in
                self.mapFeedToHashtagItem(feed: feed)
            })
            controller.displayHashtags(hashtags: hashtagItems, feeds: feeds)
        } else {
            controller.displayHashtags(hashtags: [], feeds: [])
        }
    }
    
    private func mapFeedToHashtagItem(feed: Feed) -> HashtagItem {
        let post = feed.post
        let media = post?.medias?.first
        let containingProduct = post?.product != nil
        let isMultiple = post?.medias?.count ?? 0 > 1
        let isVideo = media?.type == "video"
        
        return HashtagItem(
            id: feed.id ?? "",
            thumbnailUrl: media?.thumbnail?.small ?? "",
            thumbnailHeight: Double(
                media?.metadata?.height ?? ""
            ),
            thumbnailWidth: Double(
                media?.metadata?.width ?? ""
            ),
            thumbnailSize: Double(
                media?.metadata?.size ?? ""
            ),
            type: containingProduct ? .product : isMultiple ? .multiple : isVideo ? .video : .image
        )
    }
}
