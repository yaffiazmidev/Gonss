//
//  RemoteFollowingItem.swift
//  KipasKipas
//
//  Created by DENAZMI on 22/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

struct RemoteFollowingItem: Codable {
    let code, message: String?
    let data: RemoteFollowingData?
}

struct RemoteFollowingData: Codable {
    let content: [RemoteFollowingContent]?
}

struct RemoteFollowingContent: Codable {
    let id: String?
    let username: String?
    let name: String?
    let photo: String?
}
