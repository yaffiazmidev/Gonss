//
//  RemoteCallProfileData.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation

struct RemoteCallProfileData: Codable {
    
    let id: String?
    let username: String?
    let name: String?
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
    let socialMedias: [RemoteCallProfileSocialMedia]?
    let totalFollowers: Int?
    let totalFollowing: Int?
    let totalPost: Int?
    let urlBadge: String?
    let donationBadge: RemoteCallProfileDonationBadge?
    let isShowBadge: Bool?
    let referralCode: String?
    
}
