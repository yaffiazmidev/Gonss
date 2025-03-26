//
//  CallProfileSearchMapper.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation
import KipasKipasNetworking

final class CallProfileSearchMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [CallProfile] {
        if !response.isOK {
            if let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) {
                throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
            }
            throw KKNetworkError.connectivity
        }
        
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteCallProfileSearchResponse.self, from: data), let data = root.data else {
            throw KKNetworkError.invalidData
        }
        
        var profiles: [CallProfile] = []
        
        data.forEach({ remote in
            var socialMedias: [CallProfileSocialMedia]? = nil
            remote.socialMedias?.forEach({ media in
                socialMedias?.append(
                    CallProfileSocialMedia(
                        urlSocialMedia: media.urlSocialMedia,
                        socialMediaType: media.socialMediaType ?? ""
                    )
                )
            })
            
            var donationBadge: CallProfileDonationBadge? = nil
            if let badge = remote.donationBadge {
                donationBadge = CallProfileDonationBadge(
                    id: badge.id ?? "",
                    name: badge.name ?? "",
                    url: badge.url ?? "",
                    min:badge.min ?? 0,
                    max: badge.max ?? 0,
                    level: badge.level ?? 0,
                    isFlagUpdate: badge.isFlagUpdate ?? false,
                    globalRank: badge.globalRank ?? 0,
                    isShowBadge: badge.isShowBadge ?? false
                )
            }
            
            profiles.append(
                CallProfile(
                    id: remote.id ?? "",
                    username: remote.username ?? "",
                    name: remote.name ?? "",
                    bio: remote.bio,
                    photo: remote.photo,
                    birthDate: remote.birthDate,
                    gender: remote.gender,
                    isFollow: remote.isFollow ?? false,
                    isSeleb: remote.isSeleb ?? false,
                    mobile: remote.mobile ?? "",
                    email: remote.email ?? "",
                    accountType: remote.accountType ?? "",
                    isVerified: remote.isVerified ?? false,
                    note: remote.note,
                    isDisabled: remote.isDisabled ?? false,
                    isSeller: remote.isSeller ?? false,
                    socialMedias: socialMedias,
                    totalFollowers: remote.totalFollowers,
                    totalFollowing: remote.totalFollowing,
                    totalPost: remote.totalPost,
                    urlBadge: remote.urlBadge,
                    donationBadge: donationBadge,
                    isShowBadge: remote.isShowBadge,
                    referralCode: remote.referralCode
                )
            )
        })
        
        return profiles
    }
}
