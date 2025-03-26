//
//  ChannelEntity.swift
//  KipasKipas
//
//  Created by DENAZMI on 07/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct ChannelEntity {
    
    var numberOfElements: Int?
    var last: Bool?
    var sort: ChannelEntitySort?
    var first: Bool?
    var totalElements: Int?
    var pageable: ChannelEntityPageable?
    var content: [ChannelEntityContent]?
    var totalPages: Int?
    var number: Int?
    var size: Int?
    var empty: Bool?
    
    init(numberOfElements: Int?, last: Bool?, sort: ChannelEntitySort?, first: Bool?, totalElements: Int?, pageable: ChannelEntityPageable?, content: [ChannelEntityContent]?, totalPages: Int?, number: Int?, size: Int?, empty: Bool?) {
        self.numberOfElements = numberOfElements
        self.last = last
        self.sort = sort
        self.first = first
        self.totalElements = totalElements
        self.pageable = pageable
        self.content = content
        self.totalPages = totalPages
        self.number = number
        self.size = size
        self.empty = empty
    }
}

struct ChannelEntitySort {
    
    var sorted: Bool?
    var unsorted: Bool?
    var empty: Bool?
    
    init(sorted: Bool?, unsorted: Bool?, empty: Bool?) {
        self.sorted = sorted
        self.unsorted = unsorted
        self.empty = empty
    }
}

struct ChannelEntityPageable {
    
    var offset: Int?
    var pageNumber: Int?
    var pageSize: Int?
    var paged: Bool?
    var sort: ChannelEntitySort?
    var unpaged: Bool?
    
    init(offset: Int?, pageNumber: Int?, pageSize: Int?, paged: Bool?, sort: ChannelEntitySort?, unpaged: Bool?) {
        self.offset = offset
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.paged = paged
        self.sort = sort
        self.unpaged = unpaged
    }
}

struct ChannelEntityContent {
    
    var code: String?
    var name: String?
    var id: String?
    var createAt: Int?
    var photo: String?
    var description: String?
    var isFollow: Bool?
    
    init(code: String?, name: String?, id: String?, createAt: Int?, photo: String?, description: String?, isFollow: Bool?) {
        self.code = code
        self.name = name
        self.id = id
        self.createAt = createAt
        self.photo = photo
        self.description = description
        self.isFollow = isFollow
    }
}
