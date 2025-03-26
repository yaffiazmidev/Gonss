//
//  RemoteChannelDetailItemMapper.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteChannelDetailItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        private let data: RemoteChannelDetail
        
        var item: ChannelDetailItem {
            ChannelDetailItem(
                code: data.code ?? "",
                name: data.name ?? "",
                id: data.id ?? "",
                createAt: data.createAt ?? 0,
                photo: data.photo ?? "",
                description: data.description ?? "",
                isFollow: data.isFollow ?? false
            )
        }
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> ChannelDetailItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
