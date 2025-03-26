//
//  RemoteCoinPurchaseValidateCustomer.swift
//  KipasKipasDirectMessage
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/10/23.
//

import Foundation

///This data fetched from KipasKipas Rest
public struct RemoteCoinPurchaseValidateCustomer: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case bio
        case photo
        case birthDate
        case gender
        case isFollow
        case isSeleb
        case mobile
        case email
        case accountType
        case isVerified
        case note
        case isDisabled
        case isSeller
        case totalDonation
        case levelBadge
        case donationBadgeId
        case urlBadge
        case donationBadge
        case isShowBadge
        case referralCode
    }
    
    public var id: String?
    public var username: String?
    public var bio: String?
    public var photo: String?
    public var birthDate: String?
    public var gender: String?
    public var isFollow: Bool?
    public var isSeleb: Bool?
    public var mobile: String?
    public var email: String?
    public var accountType: String?
    public var isVerified: Bool?
    public var note: String?
    public var isDisabled: Bool?
    public var isSeller: Bool?
    public var totalDonation: Double?
    public var levelBadge: Int?
    public var donationBadgeId: String?
    public var urlBadge: String?
    public var donationBadge: String?
    public var isShowBadge: Bool?
    public var referralCode: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
        birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
        isSeleb = try container.decodeIfPresent(Bool.self, forKey: .isSeleb)
        mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        accountType = try container.decodeIfPresent(String.self, forKey: .accountType)
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
        isSeller = try container.decodeIfPresent(Bool.self, forKey: .isSeller)
        totalDonation = try container.decodeIfPresent(Double.self, forKey: .totalDonation)
        levelBadge = try container.decodeIfPresent(Int.self, forKey: .levelBadge)
        donationBadgeId = try container.decodeIfPresent(String.self, forKey: .donationBadgeId)
        urlBadge = try container.decodeIfPresent(String.self, forKey: .urlBadge)
        donationBadge = try container.decodeIfPresent(String.self, forKey: .donationBadge)
        isShowBadge = try container.decodeIfPresent(Bool.self, forKey: .isShowBadge)
        referralCode = try container.decodeIfPresent(String.self, forKey: .referralCode)
    }
}
