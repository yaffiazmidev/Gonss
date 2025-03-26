//
//  DetailTransactionProductItemMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class DetailTransactionProductItemMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> DetailTransactionProductItem {
        guard response.isOK else {
            guard let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) else {
                throw KKNetworkError.invalidData
            }
            throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
        }

        guard let root = try? JSONDecoder().decode(RemoteDetailTransactionProductItem.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        let medias: [DetailTransactionProductItemMedia] = root.medias?.map({ media in
            DetailTransactionProductItemMedia(
                id: media.id ?? "",
                type: media.type ?? "",
                url: media.url ?? "",
                thumbnail: DetailTransactionProductItemMediaThumbnail(
                    large: media.thumbnail?.large,
                    medium:  media.thumbnail?.medium,
                    small: media.thumbnail?.small
                ),
                metadata: DetailTransactionProductItemMediaMetadata(
                    width: media.metadata?.width,
                    height: media.metadata?.height,
                    size: media.metadata?.size,
                    duration: media.metadata?.duration
                ),
                isHLSReady: media.isHLSReady,
                hlsURL: media.hlsURL
            )
        }) ?? []
        
        return DetailTransactionProductItem(
            id: root.id ?? "",
            isDeleted: root.isDeleted ?? false,
            name: root.name ?? "",
            price: root.price ?? 0,
            description: root.description ?? "",
            sold: root.sold,
            measurement: DetailTransactionProductItemMeasurement(
                weight: root.measurement?.weight ?? 0,
                length: root.measurement?.length ?? 0,
                height: root.measurement?.height ?? 0,
                width: root.measurement?.width ?? 0
            ),
            medias: medias,
            accountId: root.accountId ?? "",
            sellerName: root.sellerName ?? "",
            generalStatus: root.generalStatus ?? "",
            isBanned: root.isBanned ?? false,
            reasonBanned: root.reasonBanned,
            totalSales: root.totalSales ?? 0,
            city: root.city,
            stock: root.stock ?? 0,
            productCategoryId: root.productCategoryId,
            productCategoryName: root.productCategoryName,
            modal: root.modal,
            commission: root.commission ?? 0,
            isResellerAllowed: root.isResellerAllowed ?? false,
            isAlreadyReseller: root.isAlreadyReseller ?? false,
            type: ProductType(rawValue: root.type ?? "") ?? .original,
            ratingAverage: root.ratingAverage ?? 0,
            ratingCount: root.ratingCount ?? 0,
            originalAccountId: root.originalAccountId
        )
    }
}
