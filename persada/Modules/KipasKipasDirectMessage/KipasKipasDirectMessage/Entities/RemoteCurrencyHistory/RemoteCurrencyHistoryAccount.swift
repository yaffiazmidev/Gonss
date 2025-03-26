//
//  RemoteCurrencyHistoryAccount.swift
//
//  Created by DENAZMI on 28/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteCurrencyHistoryAccount: Codable {
    
    enum CodingKeys: String, CodingKey {
        case isVerified
        case username
        case gender
        case isSeleb
        case bio
        case id
        case isSeller
        case photo
        case accountType
        case name
        case mobile
        case isFollow
        case email
    }
    
    public var isVerified: Bool?
    public var username: String?
    public var gender: String?
    public var isSeleb: Bool?
    public var bio: String?
    public var id: String?
    public var isSeller: Bool?
    public var photo: String?
    public var accountType: String?
    public var name: String?
    public var mobile: String?
    public var isFollow: Bool?
    public var email: String?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        isSeleb = try container.decodeIfPresent(Bool.self, forKey: .isSeleb)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        isSeller = try container.decodeIfPresent(Bool.self, forKey: .isSeller)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
        accountType = try container.decodeIfPresent(String.self, forKey: .accountType)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
        isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
        email = try container.decodeIfPresent(String.self, forKey: .email)
    }
    
}
