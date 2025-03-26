//
//  ReviewMediaMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 20/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

final class ReviewMediaMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> ReviewMediaData {
        if !response.isOK {
            if let error = try? JSONDecoder().decode(RemoteReviewError.self, from: data) {
                if error.code == "9000"{
                    throw RemoteReviewMediaLoader.Error.noData
                }
            }
            throw RemoteReviewLoader.Error.connectivity
        }
        
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteReviewMediaRoot.self, from: data) else {
            throw RemoteReviewMediaLoader.Error.invalidData
        }
        
        let contents: [ReviewMedia] = root.data?.content?.map({ media in
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
                username: media.username ?? "",
                photo: media.photo ?? "",
                accountId: media.accountId ?? "",
                isAnonymous: media.isAnonymous ?? false,
                review: media.review,
                rating: media.rating ?? 0,
                createAt: media.createAt ?? 0
            )
        }) ?? []
        
        
        return ReviewMediaData(
            content: contents,
            totalElements: root.data?.totalElements ?? 0,
            totalPages: root.data?.totalPages ?? 0,
            last: root.data?.last ?? true,
            first: root.data?.first ?? true
        )
    }
}

private extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
