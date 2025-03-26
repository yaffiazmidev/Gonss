//
//  RemoteReviewMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

final class ReviewMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> Review {
        if !response.isOK {
            if let error = try? JSONDecoder().decode(RemoteReviewError.self, from: data) {
                if error.code == "9000"{
                    throw RemoteReviewLoader.Error.noData
                }
            }
            throw RemoteReviewLoader.Error.connectivity
        }
        
//        do {
//            try JSONDecoder().decode(RemoteReviewRoot.self, from: data)
//        }catch let error{
//            print("*** error parsing becasue \(error)")
//        }
        
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteReviewRoot.self, from: data) else {
            throw RemoteReviewLoader.Error.invalidData
        }
        
        let reviews: [ReviewItem] = root.data?.reviews?.map({ review in
            let medias: [ReviewMedia] = review.medias?.map({ media in
                ReviewMedia(
                    id: media.id,
                    type: media.type,
                    url: media.url,
                    thumbnail: ReviewMediaThumbnail(
                        large: media.thumbnail?.large,
                        medium: media.thumbnail?.medium,
                        small: media.thumbnail?.small
                    ),
                    metadata: ReviewMediaMetadata(
                        width: media.metadata?.width ?? "",
                        height: media.metadata?.height ?? "",
                        size: media.metadata?.size ?? "",
                        duration: media.metadata?.duration
                    ),
                    isHLSReady: media.isHLSReady,
                    hlsURL: media.hlsURL,
                    username: review.username,
                    photo: review.photo ?? "",
                    accountId: media.accountId ?? review.accountId,
                    isAnonymous: review.isAnonymous,
                    review: review.review ?? "",
                    rating: review.rating,
                    createAt: media.createAt ?? review.createAt
                )
            }) ?? []
            return ReviewItem(
                username: review.username,
                photo: review.photo ?? "",
                accountId: review.accountId,
                medias: medias,
                isAnonymous: review.isAnonymous,
                review: review.review ?? "",
                rating: review.rating,
                createAt: review.createAt,
                urlBadge: review.urlBadge,
                isShowBadge: review.isShowBadge == true
            )
        }) ?? []
        
        
        return Review(
            id: root.data?.id ?? "",
            reviews: reviews,
            ratingAverage: root.data?.ratingAverage ?? 0.0,
            ratingCount: root.data?.ratingCount ?? 0,
            reviewCount: root.data?.reviewCount ?? 0
        )
    }
}

private extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
