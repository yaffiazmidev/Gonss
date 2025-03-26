//
//  QRProductItemMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class QRProductItemMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> QRProductItem {
        guard response.isOK else {
            guard let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) else {
                throw KKNetworkError.invalidData
            }
            throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
        }

        guard let root = try? JSONDecoder().decode(RemoteQRProductItemRoot.self, from: data), let product = root.data else {
            throw KKNetworkError.invalidData
        }
        
        let medias: [QRProductMediaItem] = product.medias?.map({ item in
            QRProductMediaItem(
                id: item.id,
                type: item.type,
                url: item.url,
                thumbnail: QRProductMediaThumbnailItem(
                    large: item.thumbnail?.large,
                    medium: item.thumbnail?.medium,
                    small: item.thumbnail?.small
                ),
                metadata: QRProductMediaMetadataItem(
                    width: item.metadata?.width,
                    height: item.metadata?.height,
                    size: item.metadata?.size,
                    duration: item.metadata?.duration
                ),
                isHLSReady: item.isHLSReady,
                hlsURL: item.hlsURL
            )
        }) ?? []
        
        return QRProductItem(
            id: product.id,
            isDeleted: product.isDeleted,
            name: product.name,
            price: product.price,
            description: product.description,
            sold: product.sold,
            measurement: QRProductMeasurementItem(
                weight: product.measurement?.weight,
                length: product.measurement?.length,
                height: product.measurement?.height,
                width: product.measurement?.width
            ),
            medias: medias,
            accountId: product.accountId,
            sellerName: product.sellerName,
            generalStatus: product.generalStatus,
            isBanned: product.isBanned,
            reasonBanned: product.reasonBanned,
            totalSales: product.totalSales,
            stock: product.stock,
            ratingAverage: product.ratingAverage,
            ratingCount: product.ratingCount,
            city: product.city,
            productCategoryId: product.productCategoryId,
            productCategoryName: product.productCategoryName,
            modal: product.modal,
            commission: product.commission,
            isResellerAllowed: product.isResellerAllowed,
            type: product.type,
            isAlreadyReseller: product.isAlreadyReseller,
            originalAccountId: product.originalAccountId
        )
    }
}
