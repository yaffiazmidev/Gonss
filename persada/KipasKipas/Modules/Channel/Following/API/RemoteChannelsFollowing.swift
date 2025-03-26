//
//  RemoteChannelsFollowingFollowing.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct RemoteChannelsFollowing: Codable {
    
    var numberOfElements: Int?
    var last: Bool?
    var sort: RemoteChannelsFollowingSort?
    var first: Bool?
    var totalElements: Int?
    var pageable: RemoteChannelsFollowingPageable?
    var content: [RemoteChannelsFollowingContent]?
    var totalPages: Int?
    var number: Int?
    var size: Int?
    var empty: Bool?
}

struct RemoteChannelsFollowingContent: Codable {
    
  var code: String?
  var name: String?
  var id: String?
  var createAt: Int?
  var photo: String?
  var description: String?
  var isFollow: Bool?
}

struct RemoteChannelsFollowingPageable: Codable {
    
    var offset: Int?
    var pageNumber: Int?
    var pageSize: Int?
    var paged: Bool?
    var sort: RemoteChannelsFollowingSort?
    var unpaged: Bool?
}

struct RemoteChannelsFollowingSort: Codable {
    
    var sorted: Bool?
    var unsorted: Bool?
    var empty: Bool?
}
