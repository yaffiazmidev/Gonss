//
//  RemoteFeedItemPageable.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemPageable: Codable {

  enum CodingKeys: String, CodingKey {
    case offsetPage
    case paged
    case pageNumber
    case pageSize
    case startId
    case sort
    case unpaged
    case nocache
    case offset
  }

    public var offsetPage: Int?
    public var paged: Bool?
    public var pageNumber: Int?
    public var pageSize: Int?
    public var startId: String?
    public var sort: RemoteFeedItemSort?
    public var unpaged: Bool?
    public var nocache: Bool?
    public var offset: Int?



    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    offsetPage = try container.decodeIfPresent(Int.self, forKey: .offsetPage)
    paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
    pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
    pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
    startId = try container.decodeIfPresent(String.self, forKey: .startId)
    sort = try container.decodeIfPresent(RemoteFeedItemSort.self, forKey: .sort)
    unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
    nocache = try container.decodeIfPresent(Bool.self, forKey: .nocache)
    offset = try container.decodeIfPresent(Int.self, forKey: .offset)
  }

}
