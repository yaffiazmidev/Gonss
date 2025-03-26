//
//  RemoteFollowingPageable.swift
//
//  Created by DENAZMI on 02/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFollowingPageable: Codable {

  enum CodingKeys: String, CodingKey {
    case paged
    case offset
    case pageSize
    case sort
    case unpaged
    case pageNumber
  }

    public var paged: Bool?
    public var offset: Int?
    public var pageSize: Int?
    public var sort: RemoteFollowingSort?
    public var unpaged: Bool?
    public var pageNumber: Int?



  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
    offset = try container.decodeIfPresent(Int.self, forKey: .offset)
    pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
    sort = try container.decodeIfPresent(RemoteFollowingSort.self, forKey: .sort)
    unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
    pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
  }

}
