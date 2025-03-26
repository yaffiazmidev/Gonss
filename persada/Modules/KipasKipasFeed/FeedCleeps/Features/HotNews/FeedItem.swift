//
//  FeedItem.swift
//  FeedCleeps
//
//  Created by DENAZMI on 04/10/23.
//

import Foundation
import TUIPlayerCore
import TUIPlayerShortVideo

public class FeedItem: TUIPlayerVideoModel, Codable {
    
    public var id: String?
    public var likes: Int?
    public var isLike: Bool?
    public var account: FeedAccount?
    public var post: FeedPost?
    public var typePost: String?
    public var comments: Int?
    public var trendingAt: Int?
    public var feedType: FeedType?
    public var createAt: Int?
    public var feedMediaType: FeedMediaType?
    
    public init(id: String? = nil, likes: Int? = nil, isLike: Bool? = nil, account: FeedAccount? = nil, post: FeedPost? = nil, typePost: String? = nil, comments: Int? = nil, trendingAt: Int? = nil, feedType: FeedType? = nil, createAt: Int? = nil, feedMediaType: FeedMediaType? = nil) {
        self.id = id
        self.likes = likes
        self.isLike = isLike
        self.account = account
        self.post = post
        self.typePost = typePost
        self.comments = comments
        self.trendingAt = trendingAt
        self.feedType = feedType
        self.createAt = createAt
        self.feedMediaType = feedMediaType
    }
}

public class FeedAccount: Codable {
    
    public var id: String?
    public var username: String?
    public var isVerified: Bool?
    public var name: String?
    public var photo: String?
    public var accountType: String?
    public var urlBadge: String?
    public var isShowBadge: Bool?
    public var isFollow: Bool?
    public var chatPrice: Int?
    
    
    public init(id: String? = nil, username: String? = nil, isVerified: Bool? = nil, name: String? = nil, photo: String? = nil, accountType: String? = nil, urlBadge: String? = nil, isShowBadge: Bool?, isFollow: Bool? = nil, chatPrice: Int? = nil) {
        self.id = id
        self.username = username
        self.isVerified = isVerified
        self.name = name
        self.photo = photo
        self.accountType = accountType
        self.urlBadge = urlBadge
        self.isShowBadge = isShowBadge
        self.isFollow = isFollow
        self.chatPrice = chatPrice
    }
}

public class FeedPost: Codable {
    
    public var id: String?
    public var description: String?
    public var hashtags: [FeedHashtag]?
    public var medias: [FeedMedia]?
    public var title: String?
    public var targetAmount: Double?
    public var amountCollected: Double?
    public var donationCategory: FeedDonationCategory?
    public var product: FeedProduct?
    public var floatingLink: String?
    public var floatingLinkLabel: String?
    public var siteName: String?
    public var siteLogo: String?
    public var localRanks: [DonateLocalRank]?
    public let levelPriority: Int?
    public let isDonationItem: Bool?
    
    public init(id: String? = nil, description: String? = nil, hashtags: [FeedHashtag]? = nil, medias: [FeedMedia]? = nil, title: String? = nil, targetAmount: Double? = nil, amountCollected: Double? = nil, donationCategory: FeedDonationCategory? = nil, product: FeedProduct? = nil, floatingLink: String? = nil, floatingLinkLabel: String? = nil, siteName: String? = nil, siteLogo: String? = nil, localRanks: [DonateLocalRank]? = nil, levelPriority: Int?, isDonationItem: Bool?) {
        self.id = id
        self.description = description
        self.hashtags = hashtags
        self.medias = medias
        self.title = title
        self.targetAmount = targetAmount
        self.amountCollected = amountCollected
        self.donationCategory = donationCategory
        self.product = product
        self.floatingLink = floatingLink
        self.floatingLinkLabel = floatingLinkLabel
        self.siteName = siteName
        self.siteLogo = siteLogo
        self.localRanks = localRanks
        self.levelPriority = levelPriority
        self.isDonationItem = isDonationItem
    }
}

public class FeedHashtag: Codable {
    
    public var id: String?
    public var value: String?
    public var total: Int?
    
    public init(id: String? = nil, value: String? = nil, total: Int? = nil) {
        self.id = id
        self.value = value
        self.total = total
    }
}

public class FeedProductMeasurement: Codable {
    public var weight, length, height, width: Double?
    
    public init(weight: Double? = nil, length: Double? = nil, height: Double? = nil, width: Double? = nil) {
        self.weight = weight
        self.length = length
        self.height = height
        self.width = width
    }
}

public class FeedProduct: Codable {
    
    public var accountId: String?
    public var description: String?
    public var generalStatus: String?
    public var id: String?
    public var isDeleted: Bool?
    public var measurement: FeedProductMeasurement?
    public var medias: [FeedMedia]?
    public var name: String?
    public var price: Double?
    public var sellerName: String?
    public var sold: Bool?
    public var productPages: String?
    public var reasonBanned: String?
    
    public init(accountId: String? = nil, description: String? = nil, generalStatus: String? = nil, id: String? = nil, isDeleted: Bool? = nil, measurement: FeedProductMeasurement? = nil, medias: [FeedMedia]? = nil, name: String? = nil, price: Double? = nil, sellerName: String? = nil, sold: Bool? = nil, productPages: String? = nil, reasonBanned: String? = nil) {
        self.accountId = accountId
        self.description = description
        self.generalStatus = generalStatus
        self.id = id
        self.isDeleted = isDeleted
        self.measurement = measurement
        self.medias = medias
        self.name = name
        self.price = price
        self.sellerName = sellerName
        self.sold = sold
        self.productPages = productPages
        self.reasonBanned = reasonBanned
    }
}

public class FeedDonationCategory: Codable {
    
    public var id: String?
    public var name: String?
    
    public init(id: String? = nil, name: String? = nil) {
        self.id = id
        self.name = name
    }
}

public enum MediasType: String, Codable {
    case image
    case video
}

public class FeedMedia: Codable {
    
    public var id: String?
    public var url: String?
    public var vodUrl: String?
    public var vodFileId: String?
    public var metadata: FeedMetadata?
    public var thumbnail: FeedThumbnail?
    public var type: String?
    
    public init(id: String? = nil, url: String? = nil, vodUrl: String? = nil, vodFileId: String? = nil, metadata: FeedMetadata? = nil, thumbnail: FeedThumbnail? = nil, type: String? = nil) {
        self.id = id
        self.url = url
        self.vodUrl = vodUrl
        self.vodFileId = vodFileId
        self.metadata = metadata
        self.thumbnail = thumbnail
        self.type = type
    }
    
    public var playURL: String {
        get {
            if let videoURL = vodUrl, !videoURL.isEmpty {
                return videoURL
            }
            if let videoURL = url, !videoURL.isEmpty {
                return videoURL
            }
            return ""
        }
    }
}

public class FeedThumbnail: Codable {
    public var small: String?
    public var large: String?
    public var medium: String?
    
    public init(small: String? = nil, large: String? = nil, medium: String? = nil) {
        self.small = small
        self.large = large
        self.medium = medium
    }
}

public class FeedMetadata: Codable {
    public var duration: Double?
    public var width: String?
    public var height: String?
    
    public init(duration: Double? = nil, width: String? = nil, height: String? = nil) {
        self.duration = duration
        self.width = width
        self.height = height
    }
}

public struct DonateLocalRank: Codable {
    public var id: String?
    public var localRank: Int?
    public var name: String?
    public var url: String?
    public var photo: String?
    public var totalLocalDonation: Int?
    public var isShowBadge: Bool?
    
    init(id: String? = nil, localRank: Int? = nil, name: String? = nil, url: String? = nil, photo: String? = nil, totalLocalDonation: Int? = nil, isShowBadge: Bool? = nil) {
        self.id = id
        self.localRank = localRank
        self.name = name
        self.url = url
        self.photo = photo
        self.totalLocalDonation = totalLocalDonation
        self.isShowBadge = isShowBadge
    }
}

extension [FeedItem] {
    func get(byId: String?) -> FeedItem? {
        if let index = self.firstIndex(where: { $0.id == byId }) {
            return self[index]
        }
        
        return nil
    }
    
    func getIndex(byId: String?) -> Int? {
        if let index = self.firstIndex(where: { $0.id == byId }) {
            return index
        }
        
        return nil
    }
}

extension FeedItem {
    static func from(remote item: RemoteFeedItemContent, type: FeedType?, account: RemoteUserProfileData?, feedMediaType: FeedMediaType?) -> FeedItem {
        let mediasThumbnail = item.post?.medias?.first?.thumbnail.map({
            FeedThumbnail(small: $0.small, large: $0.large, medium: $0.medium)
        })
        
        let medias = item.post?.medias?.compactMap({
            FeedMedia(id: $0.id, url: $0.url, vodUrl: $0.vodUrl, metadata: FeedMetadata(duration: $0.metadata?.duration, width: $0.metadata?.width, height: $0.metadata?.height), thumbnail: mediasThumbnail, type: $0.type)
        })
        
        let donationCategory = item.post?.donationCategory.map({
            FeedDonationCategory(id: $0.id, name: $0.name)
        })
        
        let productMeasurement = item.post?.product?.measurement.map({
            FeedProductMeasurement(weight: $0.weight, length: $0.length, height: $0.height, width: $0.width)
        })
        
        let productMedias = item.post?.product?.medias?.compactMap({
            return FeedMedia(id: $0.id, url: $0.url, vodUrl: $0.vodUrl, metadata: FeedMetadata(duration: $0.metadata?.duration, width: $0.metadata?.width, height: $0.metadata?.height), thumbnail: mediasThumbnail, type: $0.type)
        })
        
        let product = item.post?.product.map({
            FeedProduct(
                accountId: $0.accountId,
                description: $0.description,
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
        
        let hashtags = item.post?.hashtags?.map({
            FeedHashtag(
                id: $0.id,
                value: $0.value,
                total: $0.total
            )
        })
        
        let localRanks: [DonateLocalRank]? = item.post?.localRanks?.map({
            return DonateLocalRank( id: $0.id, localRank: $0.localRank, name: $0.name, url: $0.url, photo: $0.account?.photo, totalLocalDonation: $0.totalLocalDonation, isShowBadge: $0.account?.isShowBadge)
        })
        
        let post = item.post.map({
            FeedPost(
                id: $0.id,
                description: $0.descriptionValue,
                hashtags: hashtags,
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
                localRanks: localRanks,
                levelPriority: $0.levelPriority, 
                isDonationItem: $0.isDonationItem
            )
        })
        
        let feedAccount = item.account.map({
            FeedAccount(
                id: $0.id,
                username: $0.username,
                isVerified: $0.isVerified,
                name: $0.name,
                photo: $0.photo,
                accountType: $0.accountType,
                urlBadge: $0.urlBadge,
                isShowBadge: $0.isShowBadge,
                isFollow: type == .profile ? account?.isFollow : $0.isFollow,
                chatPrice: $0.chatPrice
            )
        })
        
        let feedItem = FeedItem(
            id: item.id,
            likes: item.likes,
            isLike: item.isLike,
            account: feedAccount,
            post: post,
            typePost: item.typePost,
            comments: item.comments,
            trendingAt: item.trendingAt,
            feedType: type,
            createAt: item.createAt,
            feedMediaType: feedMediaType
        )
        
        let mediaWithVodUrl = item.post?.medias?.filter({ $0.vodUrl != nil }).first
        let mediaWithoutVodUrl = item.post?.medias?.filter({ $0.url?.hasPrefix(".mp4") == true || $0.url?.hasPrefix(".m3u8") == true }).first
        
        let media = item.post?.medias?.first
        
        if type == .donation {
            feedItem.videoUrl = mediaWithVodUrl?.playURL ?? ""
        } else {
            if item.typePost == "donation" {
                feedItem.videoUrl = mediaWithVodUrl?.playURL ?? ""
            } else {
                feedItem.videoUrl = media?.playURL ?? ""
            }
        }
        
        if let mediaThumbnail = media?.thumbnail?.large {
            var mediaType: HotnewsCoverMediaType
            if media?.type == "video" {
                let isFill: Bool
                
                let width = Double(media?.metadata?.width ?? "550") ?? 550
                let height =  Double(media?.metadata?.height ?? "550") ?? 550
                
                let ratio = height / width
                if width >= height {
                    isFill = false
                } else {
                    if(ratio < 1.5){
                        isFill = false
                    } else {
                        isFill = true
                    }
                }
                
                mediaType = .video(isFill: isFill)
            } else {
                mediaType = .photo
            }
            
            feedItem.coverPictureUrl = HotnewsCoverManager.instance.url(from: mediaThumbnail, with: type ?? .hotNews, mediaType: mediaType)
        }
        
        feedItem.duration = "\(media?.metadata?.duration ?? 0)"
        
        return feedItem
    }
}
