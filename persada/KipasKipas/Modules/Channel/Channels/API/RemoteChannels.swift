//
//  RemoteChannels.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct RemoteChannels: Codable {
    
    var numberOfElements: Int?
    var last: Bool?
    var sort: RemoteChannelsSort?
    var first: Bool?
    var totalElements: Int?
    var pageable: RemoteChannelsPageable?
    var content: [RemoteChannelsContent]?
    var totalPages: Int?
    var number: Int?
    var size: Int?
    var empty: Bool?
}

struct RemoteChannelsContent: Codable {
    
  var code: String?
  var name: String?
  var id: String?
  var createAt: Int?
  var photo: String?
  var description: String?
  var isFollow: Bool?
}

struct RemoteChannelsPageable: Codable {
    
    var offset: Int?
    var pageNumber: Int?
    var pageSize: Int?
    var paged: Bool?
    var sort: RemoteChannelsSort?
    var unpaged: Bool?
}

struct RemoteChannelsSort: Codable {
    
    var sorted: Bool?
    var unsorted: Bool?
    var empty: Bool?
}
