//
//  ExplorePresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 07/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit

protocol IExplorePresenter: AnyObject {
    func presentChannels(with result: ChannelsLoader.Result)
    func presentExplorePost(with result: ChannelsGeneralPostsLoader.Result)
}

class ExplorePresenter: IExplorePresenter {
    
    weak var controller: IExploreViewController!
    
    init(controller: IExploreViewController) {
        self.controller = controller
    }
    
    func presentChannels(with result: ChannelsLoader.Result) {
        switch result {
        case .failure(let error):
            print(error)
        case .success(let response):
            controller.displayChannels(channels: response.contents ?? [])
        }
    }
    
    func presentExplorePost(with result: ChannelsGeneralPostsLoader.Result) {
        switch result {
        case .failure(let error):
            print(error)
        case .success(let response):
            handleSuccessGetExplorePosts(with: response)
        }
    }
}

extension ExplorePresenter {
    
    private func handleSuccessGetExplorePosts(with response: ChannelsGeneralPostsItem) {
        
        let contents = response.contents.compactMap({
            ExploreModel.Post(
                feedId: $0.id,
                id: $0.post?.id ?? "",
                url: $0.post?.medias?.first?.type == "video" ? $0.post?.medias?.first?.thumbnail?.large ?? "" : $0.post?.medias?.first?.url ?? "",
                height: $0.post?.medias?.first?.metadata?.height ?? "",
                size: $0.post?.medias?.first?.metadata?.size ?? "",
                width: $0.post?.medias?.first?.metadata?.width ?? "",
                type: $0.post?.product != nil ? .product : $0.post?.medias?.count ?? 0 > 1 ? .multiple : $0.post?.medias?.first?.type == "video" ? .video : .image
            )
        })
        
        controller.displayExplorePosts(contents: contents, feeds: response.contents.toFeed())
    }
}

private extension Array where Element == ChannelsGeneralPostsContent {
    func toFeed() -> [Feed] {
        return compactMap({ content in
            let medias = content.post?.medias?.compactMap({ Medias(id: $0.id, type: $0.type, url: $0.url, isHlsReady: $0.isHlsReady, hlsUrl: $0.hlsUrl, thumbnail: Thumbnail(large: $0.thumbnail?.large, medium: $0.thumbnail?.medium, small: $0.thumbnail?.small), metadata: Metadata(width: $0.metadata?.width, height: $0.metadata?.height, size: $0.metadata?.size)) })
            
            let measurement = content.post?.product?.measurement.map({
                ProductMeasurement(weight: Double($0.weight), length: Double($0.length), height: Double($0.height), width: Double($0.width))
            })
            
            let productMedias = content.post?.product?.medias?.compactMap({
                Medias(
                    id: $0.id,
                    type: $0.type,
                    url: $0.url,
                    isHlsReady: $0.isHlsReady,
                    hlsUrl: $0.hlsUrl,
                    thumbnail: Thumbnail(
                        large: $0.thumbnail?.large,
                        medium: $0.thumbnail?.medium,
                        small: $0.thumbnail?.small
                    ),
                    metadata: Metadata(
                        width: $0.metadata?.width,
                        height: $0.metadata?.height,
                        size: $0.metadata?.size
                    )
                )
            })
            
            let product = content.post?.product.map({
                Product(accountId: content.account?.id, postProductDescription: $0.description, generalStatus: $0.generalStatus, id: $0.id, isDeleted: $0.isDeleted, measurement: measurement, medias: productMedias, name: $0.name, price: Double($0.price), stock: nil, sellerName: nil, sold: nil, productPages: nil, reasonBanned: nil, totalSales: nil, city: nil, ratingAverage: nil, ratingCount: nil)
            })
            
            let channel = content.post?.channel.map({
                Channel(descriptionField: $0.description, id: $0.id, name: $0.name, photo: $0.photo, isFollow: content.account?.isFollow, code: $0.code)
            })
            
            let hashtags = content.post?.hashtags?.compactMap({
                Post.Hashtag.init(value: $0.value, total: $0.total)
            })
            
            let post = content.post.map({
                Post(type: $0.type, product: product, price: nil, channel: channel, id: $0.id, name: nil, postDescription: $0.description, medias: medias, hashtags: hashtags, amountCollected: nil, targetAmount: nil, donationCategory: nil, floatingLink: $0.floatingLink, floatingLinkLabel: $0.floatingLinkLabel, siteName: $0.siteName, siteLogo: $0.siteLogo, levelPriority: $0.levelPriority, title: nil, isDonationItem: $0.isDonationItem)
            })
            
            let account = content.account.map({
                Profile(accountType: "", bio: "", email: $0.email, id: $0.id, isFollow: $0.isFollow, birthDate: "", note: "", isDisabled: $0.isDisabled, isSeleb: $0.isSeleb, isVerified: $0.isVerified, mobile: $0.mobile, name: $0.name, photo: $0.photo, username: $0.username, isSeller: $0.isSeller, socialMedias: [], donationBadge: nil, referralCode: "", urlBadge: "", isShowBadge: false, chatPrice: $0.chatPrice
                )
            })
            
            return Feed(id: content.id, typePost: content.typePost, post: post, createAt: content.createAt, likes: content.likes, comments: content.comments, account: account, isRecomm: nil, isReported: content.isReported, isLike: content.isLike, isFollow: content.isFollow, isProductActiveExist: nil, stories: [], feedPages: nil, valueBased: nil, typeBased: nil, similarBy: nil, mediaCategory: content.mediaCategory, totalView: content.totalView
            )
        })
    }
}
