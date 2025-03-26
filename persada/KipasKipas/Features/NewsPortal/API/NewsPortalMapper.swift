//
//  NewsPortalMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class NewsPortalMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [NewsPortalData] {
        if !response.isOK {
            if let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) {
                throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
            }
            throw KKNetworkError.connectivity
        }
        
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteNewsPortal.self, from: data), let data = root.data else {
            throw KKNetworkError.invalidData
        }
        
        var items: [NewsPortalData] = []
        data.forEach { data in
            var contents: [NewsPortalItem] = []
            data.content?.forEach({ content in
                contents.append(
                    NewsPortalItem(
                        id: content.id ?? "",
                        image: content.image ?? "",
                        name: content.name ?? "",
                        url: content.url ?? "",
                        defaultQuickAccess: content.defaultQuickAccess ?? false
                    )
                )
            })
            
            items.append(
                NewsPortalData(
                    category: data.category ?? "",
                    categoryId: data.categoryId ?? "",
                    content: contents
                )
            )
        }
        
        return items
    }
}
