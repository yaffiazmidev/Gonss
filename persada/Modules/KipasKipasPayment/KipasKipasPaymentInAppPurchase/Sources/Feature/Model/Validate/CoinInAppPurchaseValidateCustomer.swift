//
//  CoinInAppPurchaseValidateCustomer.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

public struct CoinInAppPurchaseValidateCustomer: Hashable {
    
    public let id: String
    public let username: String
    public let bio: String?
    public let photo: String?
    public let birthDate: String
    public let gender: String
    public let isFollow: Bool?
    public let isSeleb: Bool?
    public let mobile: String
    public let email: String
    public let accountType: String?
    public let isVerified: Bool?
    public let note: String?
    public let isDisabled: Bool?
    public let isSeller: Bool?
    public let totalDonation: Double?
    public let levelBadge: Int?
    public let donationBadgeId: String?
    public let urlBadge: String?
    public let donationBadge: String?
    public let isShowBadge: Bool?
    public let referralCode: String?
    
    internal init(id: String, username: String, bio: String?, photo: String?, birthDate: String, gender: String, isFollow: Bool?, isSeleb: Bool?, mobile: String, email: String, accountType: String?, isVerified: Bool?, note: String?, isDisabled: Bool?, isSeller: Bool?, totalDonation: Double?, levelBadge: Int?, donationBadgeId: String?, urlBadge: String?, donationBadge: String?, isShowBadge: Bool?, referralCode: String?) {
        self.id = id
        self.username = username
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
        self.totalDonation = totalDonation
        self.levelBadge = levelBadge
        self.donationBadgeId = donationBadgeId
        self.urlBadge = urlBadge
        self.donationBadge = donationBadge
        self.isShowBadge = isShowBadge
        self.referralCode = referralCode
    }
}
