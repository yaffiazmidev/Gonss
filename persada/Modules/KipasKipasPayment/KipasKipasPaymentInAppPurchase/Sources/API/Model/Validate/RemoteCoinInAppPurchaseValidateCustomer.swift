//
//  RemoteCoinInAppPurchaseValidateCustomer.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

struct RemoteCoinInAppPurchaseValidateCustomer: Codable {
    
    let id: String?
    let username: String?
    let bio: String?
    let photo: String?
    let birthDate: String?
    let gender: String?
    let isFollow: Bool?
    let isSeleb: Bool?
    let mobile: String?
    let email: String?
    let accountType: String?
    let isVerified: Bool?
    let note: String?
    let isDisabled: Bool?
    let isSeller: Bool?
    let totalDonation: Double?
    let levelBadge: Int?
    let donationBadgeId: String?
    let urlBadge: String?
    let donationBadge: String?
    let isShowBadge: Bool?
    let referralCode: String?
    
}
