//
//  StoryAccount.swift
//  KipasKipasStory
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/06/24.
//

import Foundation

public struct StoryAccount: Codable, Equatable {
    public let id: String
    public let username: String
    public let name: String
    public let bio: String?
    public let photo: String?
    public let birthDate: String?
    public let gender: String?
    public let isFollow: Bool
    public let isFollowed: Bool
    public let isSeleb: Bool
    public let mobile: String?
    public let email: String?
    public let accountType: String
    public let isVerified: Bool
    public let note: String?
    public let isDisabled: Bool
    public let isSeller: Bool
    public let totalDonation: Double?
    public let levelBadge: Int?
    public let donationBadgeId: String?
    public let urlBadge: String?
//    public let donationBadge: [Double]? // isinya model, deactive dulu
    public let isShowBadge: Bool
    public let referralCode: String
    public let chatPrice: Int?
    public let totalFollowers: Int
    public let totalFollowing: Int
    
    public init(id: String, username: String, name: String, bio: String?, photo: String?, birthDate: String?, gender: String?, isFollow: Bool, isFollowed: Bool, isSeleb: Bool, mobile: String?, email: String?, accountType: String, isVerified: Bool, note: String?, isDisabled: Bool, isSeller: Bool, totalDonation: Double?, levelBadge: Int?, donationBadgeId: String?, urlBadge: String?, isShowBadge: Bool, referralCode: String, chatPrice: Int?, totalFollowers: Int, totalFollowing: Int) {
        self.id = id
        self.username = username
        self.name = name
        self.bio = bio
        self.photo = photo
        self.birthDate = birthDate
        self.gender = gender
        self.isFollow = isFollow
        self.isFollowed = isFollowed
        self.isSeleb = isSeleb
        self.mobile = mobile
        self.email = email
        self.accountType = accountType
        self.isVerified = isVerified
        self.note = note
        self.isDisabled = isDisabled
        self.isSeller = isSeller
        self.totalDonation = totalDonation
        self.levelBadge = levelBadge
        self.donationBadgeId = donationBadgeId
        self.urlBadge = urlBadge
        self.isShowBadge = isShowBadge
        self.referralCode = referralCode
        self.chatPrice = chatPrice
        self.totalFollowers = totalFollowers
        self.totalFollowing = totalFollowing
    }
}
