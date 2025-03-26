//
//  CallProfile.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation

public struct CallProfile: Hashable {
    
    public let id: String
    public let username: String
    public let name: String
    public let bio: String?
    public let photo: String?
    public let birthDate: String?
    public let gender: String?
    public let isFollow: Bool
    public let isSeleb: Bool
    public let mobile: String
    public let email: String
    public let accountType: String
    public let isVerified: Bool
    public let note: String?
    public let isDisabled: Bool
    public let isSeller: Bool
    public let socialMedias: [CallProfileSocialMedia]?
    public let totalFollowers: Int?
    public let totalFollowing: Int?
    public let totalPost: Int?
    public let urlBadge: String?
    public let donationBadge: CallProfileDonationBadge?
    public let isShowBadge: Bool?
    public let referralCode: String?
    
    public init(id: String, username: String, name: String, bio: String?, photo: String?, birthDate: String?, gender: String?, isFollow: Bool, isSeleb: Bool, mobile: String, email: String, accountType: String, isVerified: Bool, note: String?, isDisabled: Bool, isSeller: Bool, socialMedias: [CallProfileSocialMedia]?, totalFollowers: Int?, totalFollowing: Int?, totalPost: Int?, urlBadge: String?, donationBadge: CallProfileDonationBadge?, isShowBadge: Bool?, referralCode: String?) {
        self.id = id
        self.username = username
        self.name = name
        self.bio = bio
        self.photo = photo
        self.birthDate = birthDate
        self.gender = gender
        self.isFollow = isFollow
        self.isSeleb = isSeleb
        self.mobile = mobile
        self.email = email
        self.accountType = accountType
        self.isVerified = isVerified
        self.note = note
        self.isDisabled = isDisabled
        self.isSeller = isSeller
        self.socialMedias = socialMedias
        self.totalFollowers = totalFollowers
        self.totalFollowing = totalFollowing
        self.totalPost = totalPost
        self.urlBadge = urlBadge
        self.donationBadge = donationBadge
        self.isShowBadge = isShowBadge
        self.referralCode = referralCode
    }
}
