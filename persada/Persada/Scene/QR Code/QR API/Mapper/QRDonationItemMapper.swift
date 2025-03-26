//
//  QRDonationItemMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class QRDonationItemMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> QRDonationItem {
        guard response.isOK else {
            guard let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) else {
                throw KKNetworkError.invalidData
            }
            throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
        }

        guard let root = try? JSONDecoder().decode(RemoteQRDonationItemRoot.self, from: data), let item = root.data else {
            throw KKNetworkError.invalidData
        }
        
        let medias: [QRDonationMediaItem] = item.medias?.map({ item in
            QRDonationMediaItem(
                id: item.id,
                type: item.type,
                url: item.url,
                thumbnail: QRDonationThumbnailItem(
                    large: item.thumbnail?.large,
                    medium: item.thumbnail?.medium,
                    small: item.thumbnail?.small
                ),
                metadata: QRDonationMetadataItem(
                    width: item.metadata?.width,
                    height: item.metadata?.height,
                    size: item.metadata?.size,
                    duration: item.metadata?.duration
                ),
                isHLSReady: item.isHLSReady,
                hlsURL: item.hlsURL
            )
        }) ?? []
        
        return QRDonationItem(
            id: item.id,
            medias: medias,
            description: item.description,
            title: item.title,
            targetAmount: item.targetAmount,
            recipientName: item.recipientName,
            status: item.status,
            amountCollected: item.amountCollected,
            amountWithdraw: item.amountWithdraw,
            createAt: item.createAt,
            expiredAt: item.expiredAt,
            initiator: QRDonationInitiatorItem(
                id: item.initiator?.id,
                username: item.initiator?.username,
                name: item.initiator?.name,
                bio: item.initiator?.bio,
                photo: item.initiator?.photo,
                birthDate: item.initiator?.birthDate,
                gender: item.initiator?.gender,
                isFollow: item.initiator?.isFollow,
                isSeleb: item.initiator?.isSeleb,
                mobile: item.initiator?.mobile,
                email: item.initiator?.email,
                accountType: item.initiator?.accountType,
                isVerified: item.initiator?.isVerified,
                note: item.initiator?.note,
                isDisabled: item.initiator?.isDisabled,
                isSeller: item.initiator?.isSeller
            ),
            donationCategory: QRDonationDonationCategoryItem(
                id: item.donationCategory?.id,
                icon: item.donationCategory?.icon,
                name: item.donationCategory?.name
            ),
            latitude: item.latitude,
            longitude: item.longitude,
            province: QRDonationProvinceItem(
                id: item.province?.id,
                createBy: item.province?.createBy,
                createAt: item.province?.createAt,
                modifyBy: item.province?.modifyBy,
                modifyAt: item.province?.modifyAt,
                isDeleted: item.province?.isDeleted,
                code: item.province?.code,
                name: item.province?.name
            ),
            amountAvailable: item.amountAvailable,
            withdrawaAllowed: item.withdrawaAllowed
        )
    }
}
