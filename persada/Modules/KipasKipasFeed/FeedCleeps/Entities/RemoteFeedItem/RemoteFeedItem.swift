//
//  RemoteFeedItem.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItem: Codable {

    public enum CodingKeys: String, CodingKey {
    case data
    case code
    case message
  }

    public var data: RemoteFeedItemData?
    public var code: String?
    public var message: String?



    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    data = try container.decodeIfPresent(RemoteFeedItemData.self, forKey: .data)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    message = try container.decodeIfPresent(String.self, forKey: .message)
  }

}
