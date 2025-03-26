//
//  ProfilePostViewController.swift
//  KipasKipasProfileUI
//
//  Created by DENAZMI on 24/12/23.
//

import UIKit
import FeedCleeps

public class ProfilePostViewController: UIViewController {

    private lazy var mainView: ProfilePostView = {
        let view = ProfilePostView().loadViewFromNib() as! ProfilePostView
        view.delegate = self
        return view
    }()
    
    var posts: [RemoteFeedItemContent] = [] {
        didSet {
            mainView.posts = posts
        }
    }
    
    var user: RemoteUserProfileData?
    var currentPage: Int = 0

    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    public override func loadView() {
        view = mainView
    }
}

extension ProfilePostViewController: ProfilePostViewDelegate {
    func didSelectPost(content: RemoteFeedItemContent) {
        let feeds = posts.toFeedItem(feedType: .profile, account: user)
        let vc = HotNewsFactory.create(by: .profile, profileId: content.account?.id ?? "", page: currentPage, selectedFeedId: content.id ?? "", alreadyLoadFeeds: feeds)
        vc.configureDismissablePresentation(tintColor: .white)
        vc.hidesBottomBarWhenPushed = true
       
        let navigation = UINavigationController(rootViewController: vc)
        presentWithSlideAnimation(navigation)
    }
}

public extension Array where Element == RemoteFeedItemContent {
    func toFeedItem(feedType: FeedType, account: RemoteUserProfileData?) -> [FeedItem] {
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
            
            let post = content.post.map({
                FeedPost(
                    id: $0.id,
                    description: $0.descriptionValue,
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
                    isFollow: account?.isFollow ?? false,
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
                trendingAt: content.trendingAt,
                feedType: .profile,
                createAt: content.createAt
            )
            
//            let mediaWithVodUrl = content.post?.medias?.filter({ $0.vodUrl != nil }).first
//            let mediaWithoutVodUrl = content.post?.medias?.filter({ $0.url?.hasPrefix(".mp4") == true || $0.url?.hasPrefix(".m3u8") == true }).first
            
            let media = medias?.first
            
            item.videoUrl = media?.playURL ?? ""
            
            if let mediaThumbnail = media?.thumbnail?.small {
                
                let imageThumbnailOSS = ("\(mediaThumbnail)?x-oss-process=image/format,jpg/interlace,1/resize,w_240")
                
                item.coverPictureUrl = imageThumbnailOSS
                //print("***imageThumbnailOSS", imageThumbnailOSS)
            }
            
            item.duration = "\(media?.metadata?.duration ?? 0)"
            
            return item
        })
    }
}
