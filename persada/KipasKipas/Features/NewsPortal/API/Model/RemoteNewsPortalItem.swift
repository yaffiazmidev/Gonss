//
//  RemoteNewsPortalItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

struct RemoteNewsPortalItem: Codable {
    let id: String?
    let image: String?
    let name: String?
    let url: String?
    let defaultQuickAccess: Bool?
}
