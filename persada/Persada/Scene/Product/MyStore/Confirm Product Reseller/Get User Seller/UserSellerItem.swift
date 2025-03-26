//
//  UserSellerItem.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct UserSellerItem {
    let accountType : String?
    let bio : String?
    let email : String?
    var id : String?
    let isFollow : Bool?
    let birthDate: String?
    let note: String?
    let isDisabled: Bool?
    let isSeleb: Bool?
    let isVerified : Bool?
    let mobile : String?
    let name : String?
    let photo : String?
    let username : String?
    let isSeller: Bool?
    let socialMedias: [SocialMediaSeller]?
    
    init(accountType: String?, bio: String?, email: String?, id: String? = nil, isFollow: Bool?, birthDate: String?, note: String?, isDisabled: Bool?, isSeleb: Bool?, isVerified: Bool?, mobile: String?, name: String?, photo: String?, username: String?, isSeller: Bool?, socialMedias: [SocialMediaSeller]?) {
        self.accountType = accountType
        self.bio = bio
        self.email = email
        self.id = id
        self.isFollow = isFollow
        self.birthDate = birthDate
        self.note = note
        self.isDisabled = isDisabled
        self.isSeleb = isSeleb
        self.isVerified = isVerified
        self.mobile = mobile
        self.name = name
        self.photo = photo
        self.username = username
        self.isSeller = isSeller
        self.socialMedias = socialMedias
    }
}

struct SocialMediaSeller {
    let socialMediaType : String?
    let urlSocialMedia : String?
    
    init(socialMediaType: String?, urlSocialMedia: String?) {
        self.socialMediaType = socialMediaType
        self.urlSocialMedia = urlSocialMedia
    }
}
