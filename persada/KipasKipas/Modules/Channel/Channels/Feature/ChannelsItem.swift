//
//  ChannelsItem.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct ChannelsItem {
    
    var contents: [ChannelsItemContent]?
    var totalPages: Int
}

struct ChannelsItemContent {
    
    var code: String
    var name: String
    var id: String
    var createAt: Int
    var photo: String
    var description: String
    var isFollow: Bool
}

struct ChannelsItemPageable {
    
    var offset: Int
    var pageNumber: Int
    var pageSize: Int
    var paged: Bool
    var sort: ChannelsItemSort?
    var unpaged: Bool
}

struct ChannelsItemSort {
    
    var sorted: Bool
    var unsorted: Bool
    var empty: Bool
}
