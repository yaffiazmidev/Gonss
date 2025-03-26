//
//  RemoteChannelsFollowingItemMapper.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

import KipasKipasNetworking

class RemoteChannelsFollowingItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        private let data: RemoteChannels
        
        var item: ChannelsFollowingItem {
            ChannelsFollowingItem(
                contents: data.content?.compactMap({
                    ChannelsFollowingItemContent(
                        code: $0.code ?? "",
                        name: $0.name ?? "",
                        id: $0.id ?? "",
                        createAt: $0.createAt ?? 0,
                        photo: $0.photo ?? "",
                        description: $0.description ?? "",
                        isFollow: $0.isFollow ?? false
                    )
                }),
                totalPages: data.totalPages ?? 0
            )
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> ChannelsFollowingItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
