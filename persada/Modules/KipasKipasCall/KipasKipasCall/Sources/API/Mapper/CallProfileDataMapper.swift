//
//  CallProfileDataMapper.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation
import KipasKipasNetworking

final class CallProfileDataMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> CallProfile {
        if !response.isOK {
            if let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) {
                throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
            }
            throw KKNetworkError.connectivity
        }
        
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteCallProfileDataResponse.self, from: data), let data = root.data else {
            throw KKNetworkError.invalidData
        }
        
        var socialMedias: [CallProfileSocialMedia]? = nil
        data.socialMedias?.forEach({ media in
            socialMedias?.append(
                CallProfileSocialMedia(
                    urlSocialMedia: media.urlSocialMedia,
                    socialMediaType: media.socialMediaType ?? ""
                )
            )
        })
        
        var donationBadge: CallProfileDonationBadge? = nil
        if let badge = data.donationBadge {
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
        
        return CallProfile(
            id: data.id ?? "",
            username: data.username ?? "",
            name: data.name ?? "",
            bio: data.bio,
            photo: data.photo,
            birthDate: data.birthDate,
            gender: data.gender,
            isFollow: data.isFollow ?? false,
            isSeleb: data.isSeleb ?? false,
            mobile: data.mobile ?? "",
            email: data.email ?? "",
            accountType: data.accountType ?? "",
            isVerified: data.isVerified ?? false,
            note: data.note,
            isDisabled: data.isDisabled ?? false,
            isSeller: data.isSeller ?? false,
            socialMedias: socialMedias,
            totalFollowers: data.totalFollowers,
            totalFollowing: data.totalFollowing,
            totalPost: data.totalPost,
            urlBadge: data.urlBadge,
            donationBadge: donationBadge,
            isShowBadge: data.isShowBadge,
            referralCode: data.referralCode
        )
    }
}
