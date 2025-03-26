//
//  RemoteChannelsItemMapper.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteChannelsItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        private let data: RemoteChannels
        
        var item: ChannelsItem {
            ChannelsItem(
                contents: data.content?.compactMap({
                    ChannelsItemContent(
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
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> ChannelsItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
