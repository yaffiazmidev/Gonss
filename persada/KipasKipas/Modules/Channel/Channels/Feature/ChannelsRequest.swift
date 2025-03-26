//
//  ChannelsRequest.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct ChannelsRequest {
    let page: Int
    let isPublic: Bool
    
    init(page: Int, isPublic: Bool) {
        self.page = page
        self.isPublic = isPublic
    }
}
