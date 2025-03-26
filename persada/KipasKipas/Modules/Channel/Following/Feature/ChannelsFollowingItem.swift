//
//  ChannelsFollowingItemItem.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct ChannelsFollowingItem {
    
    var contents: [ChannelsFollowingItemContent]?
    var totalPages: Int
}

struct ChannelsFollowingItemContent {
    
  var code: String
  var name: String
  var id: String
  var createAt: Int
  var photo: String
  var description: String
  var isFollow: Bool
}

struct ChannelsFollowingItemPageable {
    
    var offset: Int
    var pageNumber: Int
    var pageSize: Int
    var paged: Bool
    var sort: ChannelsFollowingItemSort?
    var unpaged: Bool
}

struct ChannelsFollowingItemSort {
    
    var sorted: Bool
    var unsorted: Bool
    var empty: Bool
}
