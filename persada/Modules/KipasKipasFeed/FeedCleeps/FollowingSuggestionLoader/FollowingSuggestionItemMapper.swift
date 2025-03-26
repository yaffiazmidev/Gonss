//
//  FollowingSuggestionContentMapper.swift
//  FeedCleeps
//
//  Created by DENAZMI on 03/12/22.
//

import Foundation
import KipasKipasNetworking

class FollowingSuggestionContentMapper {
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> FollowingSuggestionItem {
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteFollowingSuggestion.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
//        let content = root.data?.content?.compactMap({ content in
//            FollowingSuggestionContent(
//                account: FollowingSuggestionAccount(id: content.account?.id,
//                                                    username: content.account?.username,
//                                                    name: content.account?.name,
//                                                    photo: content.account?.photo, isFollow: content.account?.isFollow),
//                feeds: content.feeds?.compactMap({ FollowingSuggestionFeed(post: FollowingSuggestionPost(id: $0.post?.id, medias: $0.post?.medias?.compactMap({ FollowingSuggestionMedia(id: $0.id, url: $0.url) }))) }))
//        }) ?? []
        
        let content = root.data?.content?.compactMap({ content in
            FollowingSuggestionContent(
                account: FollowingSuggestionAccount(id: content.account?.id,
                                                    username: content.account?.username,
                                                    name: content.account?.name,
                                                    photo: content.account?.photo, isFollow: content.account?.isFollow,
                                                    isVerified: content.account?.isVerified),
                feeds: content.feeds)
        }) ?? []
        
        return FollowingSuggestionItem(content: content, totalPage: root.data?.totalPages ?? 0)
    }
}
