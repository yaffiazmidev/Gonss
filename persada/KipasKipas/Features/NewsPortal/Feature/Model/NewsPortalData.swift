//
//  NewsPortalData.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

struct NewsPortalData: Codable {
    let category: String
    let categoryId: String
    var content: [NewsPortalItem]
    
    init(category: String, categoryId: String, content: [NewsPortalItem]) {
        self.category = category
        self.categoryId = categoryId
        self.content = content
    }
}
