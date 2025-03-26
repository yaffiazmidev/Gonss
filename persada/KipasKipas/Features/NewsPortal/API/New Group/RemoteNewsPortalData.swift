//
//  RemoteNewsPortalData.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

struct RemoteNewsPortalData: Codable {
    let category: String?
    let categoryId: String?
    var content: [RemoteNewsPortalItem]?
}
