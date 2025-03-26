//
//  NewsPortalItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

struct NewsPortalItem: Codable {
    let id: String
    let image: String
    let name: String
    let url: String
    let defaultQuickAccess: Bool
    
    init(id: String, image: String, name: String, url: String, defaultQuickAccess: Bool = false) {
        self.id = id
        self.image = image
        self.name = name
        self.url = url
        self.defaultQuickAccess = defaultQuickAccess
    }
}
