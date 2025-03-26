//
//  UserSellerItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class UserSellerItemMapper {
    private struct Root : Codable {
        let code : String?
        let data : RemoteProfileItem?
        let message : String?
        
        struct RemoteProfileItem : Codable {
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
            let socialMedias: [RemoteSocialMedia]?
        }
        
        struct RemoteSocialMedia : Codable {
            let socialMediaType : String?
            let urlSocialMedia : String?
        }
        
        var profile: UserSellerItem {
            var socialMedia: [SocialMediaSeller] = data?.socialMedias?.compactMap { item in
                return SocialMediaSeller(socialMediaType: item.socialMediaType, urlSocialMedia: item.urlSocialMedia)
            } ?? []
            return UserSellerItem(accountType: data?.accountType, bio: data?.bio, email: data?.email, isFollow: data?.isFollow, birthDate: data?.birthDate, note: data?.note, isDisabled: data?.isDisabled, isSeleb: data?.isSeleb, isVerified: data?.isVerified, mobile: data?.mobile, name: data?.name, photo: data?.photo, username: data?.username, isSeller: data?.isSeller, socialMedias: socialMedia)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> UserSellerItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.profile
    }
}
