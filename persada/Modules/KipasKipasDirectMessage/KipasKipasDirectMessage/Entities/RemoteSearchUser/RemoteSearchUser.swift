//
//  RemoteSearchUser.swift
//
//  Created by DENAZMI on 02/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteSearchUser: Codable {

  enum CodingKeys: String, CodingKey {
    case code
    case message
    case data
  }

    public var code: String?
    public var message: String?
    public var data: [RemoteSearchUserData]?



  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    data = try container.decodeIfPresent([RemoteSearchUserData].self, forKey: .data)
  }

}
