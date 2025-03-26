//
//  RemoteFollowingSort.swift
//
//  Created by DENAZMI on 02/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFollowingSort: Codable {

  enum CodingKeys: String, CodingKey {
    case sorted
    case unsorted
    case empty
  }

    public var sorted: Bool?
    public var unsorted: Bool?
    public var empty: Bool?



  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    sorted = try container.decodeIfPresent(Bool.self, forKey: .sorted)
    unsorted = try container.decodeIfPresent(Bool.self, forKey: .unsorted)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
  }

}
