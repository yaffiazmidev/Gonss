//
//  ChannelContentsRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import FeedCleeps

protocol IChannelContentsRouter {
    func navigateToCleeps(feeds: [Feed], index: Int, channelId: String)
    func navigateToDetailContent(by id: String, channelId: String, currentPage: Int, totalPage: Int, contents: [Feed], account: Profile?)
}

class ChannelContentsRouter: IChannelContentsRouter {

    weak var controller: ChannelContentsViewController?

    init(controller: ChannelContentsViewController) {
        self.controller = controller
    }

    func navigateToCleeps(feeds: [Feed], index: Int, channelId: String) {
        
    }
    
    func navigateToDetailContent(by id: String, channelId: String, currentPage: Int, totalPage: Int, contents: [Feed], account: Profile?) {
        let vc = HotNewsFactory.create(
            by: .channel,
            profileId: getIdUser(),
            page: currentPage,
            selectedFeedId: id,
            alreadyLoadFeeds: contents.toFeedItem(account: account),
            channelId: channelId
        )
        vc.bindNavigationBar(icon: .get(.arrowLeftWhite))
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: false)
    }
}

extension ChannelContentsRouter {
    static func configure(_ controller: ChannelContentsViewController) {
        let apiService = DIContainer.shared.apiDataTransferService
        let worker = ChannelContentsWorker(network: apiService)
        let presenter: IChannelContentsPresenter = ChannelContentsPresenter(controller: controller)
        let interactor: IChannelContentsInteractor = ChannelContentsInteractor(presenter: presenter, worker: worker)
        let router: IChannelContentsRouter = ChannelContentsRouter(controller: controller)

        controller.router = router
        controller.interactor = interactor
    }
}

private extension Array where Element == Feed {
    func toFeedItem(account: Profile?) -> [FeedItem] {
        return compactMap({ content in
            
            let mediasThumbnail = content.post?.medias?.first?.thumbnail.map({
                FeedThumbnail(small: $0.small, large: $0.large, medium: $0.medium)
            })
  
            let feedMetadata = content.post?.medias?.first?.metadata.map({
                FeedMetadata(duration: $0.duration, width: $0.width, height: $0.height)
            })
            
            let medias = content.post?.medias?.compactMap({
                FeedMedia(id: $0.id, url: $0.url, vodUrl: $0.vodUrl, metadata: feedMetadata, thumbnail: mediasThumbnail
                          , type: $0.type)
            })

//            let medias = content.post?.medias?.compactMap({
//                FeedMedia(id: $0.id, url: $0.url, vodUrl: $0.vodUrl, thumbnail: mediasThumbnail, type: $0.type)
//            })
            
            let donationCategory = content.post?.donationCategory.map({
                FeedDonationCategory(id: $0.id, name: $0.name)
            })
            
            let productMeasurement = content.post?.product?.measurement.map({
                FeedProductMeasurement(weight: $0.weight, length: $0.length, height: $0.height, width: $0.width)
            })
            
            let productMedias = content.post?.product?.medias?.compactMap({
                FeedMedia(id: $0.id, url: $0.url, vodUrl: $0.vodUrl, thumbnail: mediasThumbnail, type: $0.type)
            })
            
            let product = content.post?.product.map({
                FeedProduct(
                    accountId: $0.accountId,
                    description: $0.postProductDescription,
                    generalStatus: $0.generalStatus,
                    id: $0.id,
                    isDeleted: $0.isDeleted,
                    measurement: productMeasurement,
                    medias: productMedias,
                    name: $0.name,
                    price: $0.price,
                    sellerName: $0.sellerName,
                    sold: $0.sold,
                    productPages: $0.productPages,
                    reasonBanned: $0.reasonBanned
                )
            })
            
            let post = content.post.map({
                FeedPost(
                    id: $0.id,
                    description: $0.postDescription,
                    medias: medias,
                    title: $0.title,
                    targetAmount: $0.targetAmount,
                    amountCollected: $0.amountCollected,
                    donationCategory: donationCategory,
                    product: product,
                    floatingLink: $0.floatingLink,
                    floatingLinkLabel: $0.floatingLinkLabel,
                    siteName: $0.siteName,
                    siteLogo: $0.siteLogo, 
                    levelPriority: $0.levelPriority, 
                    isDonationItem: $0.isDonationItem
                )
            })
            
            let account = content.account.map({
                FeedAccount(
                    id: $0.id,
                    username: $0.username,
                    isVerified: $0.isVerified,
                    name: $0.name,
                    photo: $0.photo,
                    accountType: $0.accountType,
                    urlBadge: $0.urlBadge,
                    isShowBadge: $0.isShowBadge,
                    isFollow: account?.isFollow,
                    chatPrice: $0.chatPrice
                )
            })
            
            let item = FeedItem(
                id: content.id,
                likes: content.likes,
                isLike: content.isLike,
                account: account,
                post: post,
                typePost: content.typePost,
                comments: content.comments,
                trendingAt: 0,
                feedType: .channel,
                createAt: content.createAt
            )
            
            let mediaWithVodUrl = content.post?.medias?.filter({ $0.vodUrl != nil }).first
            let mediaWithoutVodUrl = content.post?.medias?.filter({ $0.url?.hasPrefix(".mp4") == true || $0.url?.hasPrefix(".m3u8") == true }).first
            let media = medias?.first
            
            if content.typePost == "donation" {
                item.videoUrl = mediaWithVodUrl?.vodUrl ?? mediaWithoutVodUrl?.url ?? ""
            } else {
                item.videoUrl = media?.playURL ?? ""
            }
            
            if let mediaThumbnail = media?.thumbnail?.large {
                
                let imageThumbnailOSS = ("\(mediaThumbnail)?x-oss-process=image/format,jpg/interlace,1/resize,w_360")
                
                item.coverPictureUrl = imageThumbnailOSS
                //print("***imageThumbnailOSS", imageThumbnailOSS)
            }
            
            item.duration = "\(media?.metadata?.duration ?? 0)"
            
            return item
        })
    }
}
