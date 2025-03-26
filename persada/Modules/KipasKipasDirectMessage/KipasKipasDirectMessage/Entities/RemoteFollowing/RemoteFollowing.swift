//
//  RemoteFollowing.swift
//
//  Created by DENAZMI on 02/08/23
//  Copyright (c) . All rights reserved.
//

//import Foundation
//
//#warning("[BEKA] get rid of this")
//public struct RemoteFollowing: Codable {
//
//  enum CodingKeys: String, CodingKey {
//    case message
//    case data
//    case code
//  }
//
//    public var message: String?
//    public var data: RemoteFollowingData?
//    public var code: String?
//
//
//
//  public init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    message = try container.decodeIfPresent(String.self, forKey: .message)
//    data = try container.decodeIfPresent(RemoteFollowingData.self, forKey: .data)
//    code = try container.decodeIfPresent(String.self, forKey: .code)
//  }
//}
