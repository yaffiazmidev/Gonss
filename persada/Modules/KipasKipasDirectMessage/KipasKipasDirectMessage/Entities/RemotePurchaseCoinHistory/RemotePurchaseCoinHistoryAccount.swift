//
//  RemotePurchaseCoinHistoryAccount.swift
//
//  Created by DENAZMI on 25/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemotePurchaseCoinHistoryAccount: Codable {
    
    enum CodingKeys: String, CodingKey {
        case isSeleb
        case isVerified
        case gender
        case username
        case isDisabled
        case bio
        case birthDate
        case accountType
        case id
        case isSeller
        case photo
        case name
        case isFollow
        case mobile
        case email
    }
    
    public var isSeleb: Bool?
    public var isVerified: Bool?
    public var gender: String?
    public var username: String?
    public var isDisabled: Bool?
    public var bio: String?
    public var birthDate: String?
    public var accountType: String?
    public var id: String?
    public var isSeller: Bool?
    public var photo: String?
    public var name: String?
    public var isFollow: Bool?
    public var mobile: String?
    public var email: String?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSeleb = try container.decodeIfPresent(Bool.self, forKey: .isSeleb)
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate)
        accountType = try container.decodeIfPresent(String.self, forKey: .accountType)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        isSeller = try container.decodeIfPresent(Bool.self, forKey: .isSeller)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
        mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
        email = try container.decodeIfPresent(String.self, forKey: .email)
    }
    
}
