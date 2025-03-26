//
//  RemoteFeedItemSort.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemSort: Codable {

  enum CodingKeys: String, CodingKey {
    case unsorted
    case empty
    case sorted
  }

    public var unsorted: Bool?
    public var empty: Bool?
    public var sorted: Bool?



    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    unsorted = try container.decodeIfPresent(Bool.self, forKey: .unsorted)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
    sorted = try container.decodeIfPresent(Bool.self, forKey: .sorted)
  }

}
