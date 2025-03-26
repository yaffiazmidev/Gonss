//
//  ProductArrayMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class ProductArrayMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> ProductArrayItem {
        guard response.isOK else {
            guard let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) else {
                throw KKNetworkError.invalidData
            }
            throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
        }

        guard let root = try? JSONDecoder().decode(RemoteProductArrayItem.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        let data: [ProductItem] =  root.data?.content?.map({ product in
            let medias: [ProductItemMedia] = product.medias?.map({ media in
                ProductItemMedia(
                    id: media.id ?? "",
                    type: media.type ?? "",
                    url: media.url ?? "",
                    thumbnail: ProductItemMediaThumbnail(
                        large: media.thumbnail?.large,
                        medium:  media.thumbnail?.medium,
                        small: media.thumbnail?.small
                    ),
                    metadata: ProductItemMediaMetadata(
                        width: media.metadata?.width,
                        height: media.metadata?.height,
                        size: media.metadata?.size,
                        duration: media.metadata?.duration
                    ),
                    isHLSReady: media.isHLSReady,
                    hlsURL: media.hlsURL
                )
            }) ?? []
            
            return ProductItem(
                id: product.id ?? "",
                isDeleted: product.isDeleted ?? false,
                name: product.name ?? "",
                price: product.price ?? 0,
                description: product.description ?? "",
                sold: product.sold,
                measurement: ProductItemMeasurement(
                    weight: product.measurement?.weight ?? 0,
                    length: product.measurement?.length ?? 0,
                    height: product.measurement?.height ?? 0,
                    width: product.measurement?.width ?? 0
                ),
                medias: medias,
                accountId: product.accountId ?? "",
                sellerName: product.sellerName ?? "",
                generalStatus: product.generalStatus ?? "",
                isBanned: product.isBanned ?? false,
                reasonBanned: product.reasonBanned,
                totalSales: product.totalSales ?? 0,
                city: product.city,
                stock: product.stock ?? 0,
                productCategoryId: product.productCategoryId,
                productCategoryName: product.productCategoryName,
                modal: product.modal,
                commission: product.commission ?? 0,
                isResellerAllowed: product.isResellerAllowed ?? false,
                isAlreadyReseller: product.isAlreadyReseller ?? false,
                type: ProductType(rawValue: product.type ?? "") ?? .original,
                ratingAverage: product.ratingAverage ?? 0,
                ratingCount: product.ratingCount ?? 0,
                originalAccountId: product.originalAccountId
            )
        }) ?? []
        
        return ProductArrayItem(data: data, totalPages: root.data?.totalPages ?? 1)
    }
}
