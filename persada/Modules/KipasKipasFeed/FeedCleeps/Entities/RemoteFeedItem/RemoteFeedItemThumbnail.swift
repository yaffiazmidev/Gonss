//
//  RemoteFeedItemThumbnail.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemThumbnail: Codable {

  enum CodingKeys: String, CodingKey {
    case medium
    case small
    case large
  }

    public var medium: String?
    public var small: String?
    public var large: String?



    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    medium = try container.decodeIfPresent(String.self, forKey: .medium)
    small = try container.decodeIfPresent(String.self, forKey: .small)
    large = try container.decodeIfPresent(String.self, forKey: .large)
  }

}
