//
//  ChannelsGeneralPostsRequest.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct ChannelsGeneralPostsRequest {
    let page: Int
    let isPublic: Bool
    
    init(page: Int, isPublic: Bool) {
        self.page = page
        self.isPublic = isPublic
    }
}
