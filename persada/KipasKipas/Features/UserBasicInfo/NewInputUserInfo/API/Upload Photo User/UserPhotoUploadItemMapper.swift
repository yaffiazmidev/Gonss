//
//  UserPhotoItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class UserPhotoUploadItemMapper {
    private struct Root: Decodable {
        let url: String
        
        var item: UserPhotoItem {
            UserPhotoItem(url: url)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> UserPhotoItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
