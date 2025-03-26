//
//  ChannelMapper.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

extension RemoteChannelData {
    func map() -> ChannelEntity {
        let sort = ChannelEntitySort(sorted: sort?.sorted, unsorted: sort?.unsorted, empty: sort?.empty)
        let pageable = ChannelEntityPageable(offset: pageable?.offset, pageNumber: pageable?.pageNumber, pageSize: pageable?.pageSize, paged: pageable?.paged, sort: sort, unpaged: pageable?.unpaged)
        let content = content?.compactMap({ChannelEntityContent(code: $0.code, name: $0.name, id: $0.id, createAt: $0.createAt, photo: $0.photo, description: $0.description, isFollow: $0.isFollow)})
        
        return ChannelEntity(numberOfElements: numberOfElements, last: last, sort: sort, first: first, totalElements: totalElements, pageable: pageable, content: content, totalPages: totalPages, number: number, size: size, empty: empty)
    }
}

extension RemoteChannelGeneralPostData {
    func map() -> ChannelGeneralPostEntity {
        let content = content?.compactMap({ $0.map() })
        return ChannelGeneralPostEntity(content: content, first: first, numberOfElements: numberOfElements, totalElements: totalElements, totalPages: totalPages, last: last, number: number, empty: empty, size: size)
    }
}

private extension RemoteChannelGeneralPostContent {
    func map() -> ChannelGeneralPostEntityContent {
        let _channel = post?.channel
        let channel = ChannelGeneralPostEntityChannel(name: _channel?.name, description: _channel?.descriptionValue, photo: _channel?.photo, createAt: _channel?.createAt, id: _channel?.id, code: _channel?.code)
        
        let medias = post?.medias?.compactMap({ChannelGeneralPostEntityMedias(
            isHlsReady: $0.isHlsReady, url: $0.url, hlsUrl: $0.hlsUrl, type: $0.type,
            thumbnail: ChannelGeneralPostEntityThumbnail(large: $0.thumbnail?.large, medium: $0.thumbnail?.medium, small: $0.thumbnail?.small), id: $0.id,
            metadata: ChannelGeneralPostEntityMetadata(height: $0.metadata?.height, size: $0.metadata?.size, width: $0.metadata?.width))})
        
        var measurement: ChannelGeneralPostEntityMeasurement?
        if let _measurement = post?.product?.measurement {
            measurement = ChannelGeneralPostEntityMeasurement(width: _measurement.width, height: _measurement.height, weight: _measurement.weight, length: _measurement.length)
        }
        
        var product: ChannelGeneralPostEntityProduct?
        if let _product = post?.product {
            product = ChannelGeneralPostEntityProduct(id: _product.id, price: _product.price, name: _product.name, measurement: measurement, description: _product.descriptionValue, isBanned: _product.isBanned, generalStatus: _product.generalStatus, isDeleted: _product.isDeleted)
        }
        
        let hashtags = post?.hashtags?.compactMap({ChannelGeneralPostEntityHashtags(value: $0.value, total: $0.total)})
        let post = ChannelGeneralPostEntityPost(id: post?.id, channel: channel, hashtags: hashtags, type: post?.type, description: post?.descriptionValue, medias: medias, product: product)
        
        let account = ChannelGeneralPostEntityAccount(id: account?.id, isDisabled: account?.isDisabled, name: account?.name,
                                           isSeleb: account?.isSeleb, username: account?.username, email: account?.email,
                                           isVerified: account?.isVerified, isSeller: account?.isSeller, mobile: account?.mobile,
                                           isFollow: account?.isFollow, photo: account?.photo)
        
        return ChannelGeneralPostEntityContent(createAt: createAt, isReported: isReported,isFollow: isFollow, likes: likes, isLike: isLike, account: account, typePost: typePost, stories: stories, id: id, post: post, comments: comments, mediaCategory: mediaCategory, totalView: totalView)
    }
}
