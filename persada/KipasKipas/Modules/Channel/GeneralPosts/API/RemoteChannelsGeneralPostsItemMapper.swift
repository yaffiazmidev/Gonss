//
//  RemoteChannelsGeneralPostsMapper.swift
//  KipasKipas
//
//  Created by DENAZMI on 17/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

import KipasKipasNetworking

class RemoteChannelsGeneralPostsItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        private let data: RemoteChannelsGeneralPost
        
        var item: ChannelsGeneralPostsItem {
            ChannelsGeneralPostsItem(contents: data.content?.toModels() ?? [], totalPage: data.totalPages ?? 0)
        }
    }
    
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> ChannelsGeneralPostsItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}


private extension Array where Element == RemoteChannelsGeneralPostContent {
    func toModels() -> [ChannelsGeneralPostsContent] {
        return compactMap({ feed in
            let account = feed.account.map({
                ChannelsGeneralPostsContentAccount(
                    id: $0.id ?? "",
                    isDisabled: $0.isDisabled ?? false,
                    name: $0.name ?? "",
                    isSeleb: $0.isSeleb ?? false,
                    username: $0.username ?? "",
                    email: $0.email ?? "",
                    isVerified: $0.isVerified ?? false,
                    isSeller: $0.isSeller ?? false,
                    mobile: $0.mobile ?? "",
                    isFollow: $0.isFollow ?? false,
                    photo: $0.photo ?? "",
                    chatPrice: $0.chatPrice ?? 0
                )
            })
            
            let channel = feed.post?.channel.map({
                ChannelsGeneralPostsContentChannel(
                    name: $0.name ?? "",
                    description: $0.description ?? "",
                    photo: $0.photo ?? "",
                    createAt: $0.createAt ?? 0,
                    id: $0.id ?? "",
                    code: $0.code ?? ""
                )
            })
            
            let product =  feed.post?.product.map({
                ChannelsGeneralPostsContentProduct(
                    id: $0.id ?? "",
                    price: $0.price ?? 0,
                    name: $0.name ?? "",
                    measurement: $0.measurement.map({
                        ChannelsGeneralPostsContentMeasurement(
                            width: $0.width ?? 0.0,
                            height: $0.height ?? 0.0,
                            weight: $0.weight ?? 0.0,
                            length: $0.length ?? 0.0
                        )
                    }),
                    description: $0.description ?? "",
                    isBanned: $0.isBanned ?? false,
                    generalStatus: $0.generalStatus ?? "",
                    isDeleted: $0.isDeleted ?? false,
                    medias: $0.medias?.compactMap({ media in
                        let thumbnail = media.thumbnail.map({
                            ChannelsGeneralPostsContentThumbnail(
                                large: $0.large ?? "", medium: $0.medium ?? "", small: $0.small ?? ""
                            )
                        })
                        
                        let metadata = media.metadata.map({
                            ChannelsGeneralPostsContentMetadata(
                                height: $0.height ?? "", size: $0.size ?? "", width: $0.width ?? ""
                            )
                        })
                        
                        return ChannelsGeneralPostsContentMedias(
                            isHlsReady: media.isHlsReady ?? false,
                            url: media.url ?? "",
                            hlsUrl: media.hlsUrl ?? "",
                            type: media.type ?? "",
                            thumbnail: thumbnail,
                            id: media.id ?? "",
                            metadata: metadata
                        )
                    })
                )
            })
            
            let post = feed.post.map({
                ChannelsGeneralPostsContentPost(
                    id: $0.id ?? "",
                    channel: channel,
                    hashtags: $0.hashtags?.compactMap({
                        ChannelsGeneralPostsContentHashtags(
                            value: $0.value ?? "", total: $0.total ?? 0
                        )
                    }),
                    type: $0.type ?? "",
                    description: $0.description ?? "",
                    medias: $0.medias?.compactMap({ media in
                        let thumbnail = media.thumbnail.map({
                            ChannelsGeneralPostsContentThumbnail(
                                large: $0.large ?? "", medium: $0.medium ?? "", small: $0.small ?? ""
                            )
                        })
                        
                        let metadata = media.metadata.map({
                            ChannelsGeneralPostsContentMetadata(
                                height: $0.height ?? "", size: $0.size ?? "", width: $0.width ?? ""
                            )
                        })
                        
                        return ChannelsGeneralPostsContentMedias(
                            isHlsReady: media.isHlsReady ?? false,
                            url: media.url ?? "",
                            hlsUrl: media.hlsUrl ?? "",
                            type: media.type ?? "",
                            thumbnail: thumbnail,
                            id: media.id ?? "",
                            metadata: metadata
                        )
                    }),
                    product: product,
                    floatingLink: $0.floatingLink,
                    floatingLinkLabel: $0.floatingLinkLabel,
                    siteName: $0.siteName,
                    siteLogo: $0.siteLogo, 
                    levelPriority: $0.levelPriority, 
                    isDonationItem: $0.isDonationItem
                )
            })
            
            return ChannelsGeneralPostsContent(
                createAt: feed.createAt ?? 0,
                isReported: feed.isReported ?? false,
                isFollow: feed.isFollow ?? false,
                likes: feed.likes ?? 0,
                isLike: feed.isLike ?? false,
                account: account,
                typePost: feed.typePost ?? "",
                stories: feed.stories.map({ $0 }),
                id: feed.id ?? "",
                post: post,
                comments: feed.comments ?? 0,
                mediaCategory: feed.mediaCategory ?? ""
            )
        })
    }
}
