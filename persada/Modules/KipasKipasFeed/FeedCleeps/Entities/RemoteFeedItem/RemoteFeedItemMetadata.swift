//
//  RemoteFeedItemMetadata.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemMetadata: Codable {

  enum CodingKeys: String, CodingKey {
    case size
    case width
    case height
    case duration
  }

    public var size: String?
    public var width: String?
    public var height: String?
    public var duration: Double?



    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    size = try container.decodeIfPresent(String.self, forKey: .size)
    width = try container.decodeIfPresent(String.self, forKey: .width)
    height = try container.decodeIfPresent(String.self, forKey: .height)
    duration = try container.decodeIfPresent(Double.self, forKey: .duration)
  }

}
