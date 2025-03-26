//
//  RemoteMediaEntity.swift
//  KipasKipas
//
//  Created by DENAZMI on 13/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct RemoteMediaEntity: Codable {
    let code, message: String?
    let data: RemoteMediaEntityData?
}

struct RemoteMediaEntityData: Codable {
    let id: String?
    let type: String?
    let url: String?
    let thumbnail: RemoteMediaEntityThumbnail?
    let metadata: RemoteMediaEntityMetadata?
}

struct RemoteMediaEntityThumbnail: Codable {
    
    var large: String?
    var medium: String?
    var small: String?
    
    enum CodingKeys: String, CodingKey {
        case large = "large"
        case medium = "medium"
        case small = "small"
    }
}

struct RemoteMediaEntityMetadata: Codable {
    let width: String?
    let height: String?
    let size: String?
    var duration: Double?
    
    enum CodingKeys: String, CodingKey {
        case height = "height"
        case size = "size"
        case width = "width"
        case duration
    }
}
