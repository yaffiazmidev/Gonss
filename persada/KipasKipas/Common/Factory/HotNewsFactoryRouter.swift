//
//  HotNewsFactoryRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 13/11/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import FeedCleeps
import KipasKipasNetworking
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import KipasKipasShared
import KipasKipasDonationCart
import KipasKipasStory

class HotNewsFactoryRouter: IHotNewsRouter {
    

    private weak var controller: IHotNewsViewController?
    private let feedType: FeedType
    
    public init(controller: IHotNewsViewController?, feedType: FeedType) {
        self.controller = controller
        self.feedType = feedType
    }
    
    func presentLoginPopUp(onDismiss: (() -> Void)?) {
        showLogin?()
    }
    
    func presentComment(feed: FeedItem?) {
        
        guard AUTH.isLogin() else {
            presentLoginPopUp(onDismiss: nil)
            return
        }
        
        let commentVc = CommentHalftController(
            postId: feed?.id ?? "",
            postAccountId: feed?.account?.id ?? "",
            postAccountIsVerified: feed?.account?.isVerified ?? false,
            identifier: "CLEEPS_INDO",
            chatPrice: feed?.account?.chatPrice ?? 1
        )
        
        commentVc.handleClickUser = { [weak self ] id, type in
            guard let self = self else { return }
            self.onClickProfile(id: id, type: type)
        }
        
        commentVc.handleClickHashtag = { [weak self] hashtag in
            guard let self = self else { return }
            self.onClickHashtag(hashtag: hashtag, selectedFeedId: feed?.id ?? "")
        }
        
        commentVc.commentCountCallback = { [weak self] count in
            guard let self = self else { return }
            guard let index = self.controller?.viewsFeeds.firstIndex(where: { $0.videoUrl == feed?.videoUrl }) else { return }
            self.controller?.viewsFeeds[index].comments = commentVc.interactor.totalComments
            let feed = self.controller?.viewsFeeds[index]
            NotificationCenter.default.post(name: .handleUpdateHotNewsCellComments, object: feed)
            NotificationCenter.default.post(
                name: Notification.Name("handleUpdateHotNewsCellCommentsFromProfileFeed"),
                object: nil,
                userInfo: [
                    "postId": feed?.post?.id ?? "",
                    "accountId": feed?.account?.id ?? "",
                    "comments": feed?.comments ?? 0
                ]
            )
        }
        
        commentVc.handleStartPaidDM = { [weak self] in
            commentVc.dismiss(animated: false) {
                self?.presentShortcutStartPaidDM(feed: feed)
            }
        }
        
        commentVc.shouldResumeFeed = { [weak self] in
            self?.controller?.resumeIfNeeded()
        }
        
        let nav = UINavigationController(rootViewController: commentVc)
        nav.modalPresentationStyle = .overFullScreen
        controller?.present(nav, animated: false)
    }
    
    func presentShare(feed: FeedItem?) {
        onClickShare(item: feed)
    }
    
    func presentProfile(feed: FeedItem?) {
        guard AUTH.isLogin() else {
            showLogin?()
            return
        }
        
        controller?.pause()
        let accountId = feed?.account?.id ?? ""
        let accountType = feed?.account?.accountType ?? ""
        self.onClickProfile(id: accountId, type: accountType) { isFollow in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.controller?.updateIsFollow(accountId: accountId, isFollow: isFollow)
            }
        }
    }
    
    func presentNewsPortal(url: String) {
        let vc = NewsPortalMenuRouter.create()
        vc.onDismiss = { [weak self] in
            guard let self = self else { return }
            self.controller?.resume()
        }
        
        controller?.present(vc, animated: true)
    }
    
    func presentHashtag(feed: FeedItem?, value: String?) {
        guard AUTH.isLogin() else {
            showLogin?()
            return
        }
        
        controller?.pause()
        
        let hashtagVC = HashtagViewController(hashtag: value ?? "", selectedFeedId: feed?.id ?? "")
        hashtagVC.handleUpdateSelectedFeed = { feed in
            NotificationCenter.default.post(
                name: Notification.Name("handleUpdateHotNewsCellLikesFromProfileFeed"),
                object: nil,
                userInfo: [
                    "postId": feed.post?.id ?? "",
                    "feedId": feed.id ?? "",
                    "accountId": feed.account?.id ?? "",
                    "likes": feed.likes ?? 0,
                    "isLike": feed.isLike ?? false,
                    "comments": feed.comments ?? 0
                ]
            )
        }
        hashtagVC.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(hashtagVC, animated: true)
    }
    
    func presentMention(id: String?, type: String?) {
        guard AUTH.isLogin() else {
           showLogin?()
            return
        }
        
        controller?.pause()
        
        guard let id = id, !id.isEmpty, let type = type, !type.isEmpty else {
            onClickEmptyProfile()
            return
        }
        
        onClickProfile(id: id, type: type)
    }
    
    func presentDonationNow(feed: FeedItem?) {
        controller?.pause()
        onClickDonationCard(item: feed)
    }
    
    func presentDonationCart(feed: FeedItem?) {
        guard let feed = feed else { return }
        guard AUTH.isLogin() else {
            showLogin?()
            return
        }
        
        if DonationCartManager.instance.isAdded(id: feed.id ?? "") {
            showCartDonation()
        } else {
            showInputAmountDonation(from: feed)
        }
    }
    
    func presentDonationFilterCategory(id: String?) {
        onClickDonationCategory(categoryId: id ?? "") { [weak self] categoryId in
            guard let self = self else { return }
            self.controller?.refreshDonation(categoryId: categoryId)
        }
    }
    
    func presentShortcutStartPaidDM(feed: FeedItem?) {
        guard AUTH.isLogin() else {
           showLogin?()
            return
        }
        
        controller?.pause()
        MyCurrencyInfo.shared.requestMyCoin { [weak self] currency, error in
            if let error = error as? DataTransferError {
                if error.statusCode != 404 {
                    Toast.share.show(message: error.message)
                    return
                }
            }
            
            guard currency?.coinAmount ?? 0 >= 5 else {
                self?.navController()?.presentKKPopUpView(
                    title: "Yah koin yang kamu punya tidak cukup untuk memulai sesi pesan berbayar",
                    message: "Beli Koin kipaskipas untuk memulai sesi berbayar",
                    imageName: "imageSad",
                    cancelButtonTitle: "Kirim Pesan Biasa",
                    actionButtonTitle: "Beli Koin Kipaskipas",
                    onActionTap: { [weak self] in
                        self?.navigateToPurchaseCoin()
                    },
                    onCancelTap: { [weak self] in
                        self?.onClickShortcutStartPaidDM(feed: feed)
                    },
                    onCloseTap: { [weak self] in
                        self?.controller?.resume()
                    }
                )
                return
            }
            
            self?.onClickShortcutStartPaidDM(feed: feed)
        }
    }
    
    func presentIconFollow(feed: FeedItem?) {
        DispatchQueue.main.async {
            self.controller?.requestUpdateIsFollow(
                accountId: feed?.account?.id ?? "",
                isFollow: feed?.account?.isFollow ?? false
            )
        }
    }
    
    func presentProductDetail(feed: FeedItem?) {
        controller?.pause()
        onClickCardProduct(feed: feed)
    }
    
    func gotoLiveStreamingList() {
        showLiveStreamingList?(nil)
    }
    
    func presentPublicEmptyPopup() {
        let vc = CustomPopUpViewController(
            title: .get(.publicEmptyContentTitle),
            description: .get(.publicEmptyContentDescription),
            iconImage: UIImage(named: .get(.imageContentEmpty)),
            iconHeight: 200,
            withOption: false,
            cancelBtnTitle: "Kembali",
            okBtnTitle: "Login KipasKipas",
            isHideIcon: false,
            okBtnBgColor: .primary,
            actionStackAxis: .vertical
        )
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: true)
        
        guard vc.mainStackView != nil else { return }
        
        vc.mainStackView.spacing = 22
        vc.mainStackView.layoutMargins = UIEdgeInsets(top: 60, left: 20, bottom: 20, right: 20)
        
        vc.textStackView.spacing = 8
        vc.textStackView.layoutMargins = .init(horizontal: 10, vertical: 0)
        vc.textStackView.isLayoutMarginsRelativeArrangement = true
        
        vc.actionStackView.spacing = 12
        
        vc.titleLabel.textAlignment = .center
        vc.titleLabel.textColor = .black
        vc.titleLabel.font = .Roboto(.bold, size: 14)
        vc.descLabel.textAlignment = .center
        vc.descLabel.textColor = .grey
        vc.descLabel.font = .Roboto(.regular, size: 12)
        
        vc.handleTapOKButton = {
            vc.dismiss(animated: true)
            showLogin?()
        }
        
        vc.handleTapOKButton = {
            vc.dismiss(animated: true)
            showLogin?()
        }
    }
    
    public func presentFloatingLink(url: String) {
//        let vc = CustomPopUpViewController(title: "Apa kamu yakin akan membuka link ini?", description: url, okBtnTitle: "Ya, buka link", isHideIcon: true)
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overFullScreen
//        controller?.present(vc, animated: true)
//        
//        guard vc.mainStackView != nil else { return }
//        
//        vc.mainStackView.layoutMargins = UIEdgeInsets(top: 30, left: 20, bottom: 24, right: 20)
//        vc.mainStackView.spacing = 20
//        
//        vc.textStackView.spacing = 8
//        vc.actionStackView.spacing = 8
//        
//        vc.titleLabel.textAlignment = .center
//        vc.titleLabel.textColor = .black
//        vc.titleLabel.font = .Roboto(.bold, size: 14)
//        vc.descLabel.textAlignment = .center
//        vc.descLabel.textColor = .secondary
//        vc.descLabel.font = .Roboto(.medium, size: 12)
//        vc.descLabel.numberOfLines = 2
//        vc.descLabel.lineBreakMode = .byTruncatingTail
//        
//        vc.cancelButton.isHidden = false
//        vc.cancelButton.text("Tidak")
//        vc.okButton.backgroundColor = .primary
//        vc.handleTapOKButton = { [weak self] in
//            self?.navigateToFloatingLinkWebView(url: url)
//        }
        
//        navigateToFloatingLinkWebView(url: url)
        let vc = CustomPopUpViewController(
            title: "Fitur sedang dalam proses pengembangan.",
            description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
            iconImage: UIImage(named: "img_in_progress"),
            iconHeight: 99
        )
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: false)
    }
    
    func navigateToFloatingLinkWebView(url: String) {
        let vc = FloatingLinkWebViewController(url)
        vc.hidesBottomBarWhenPushed = true
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate, let controller = delegate.window?.topViewController {
            controller.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        controller?.present(vc, animated: true)
    }
    
    
    func navigateToPurchaseCoin() {
        let vc = CoinPurchaseRouter.create(baseUrl: APIConstants.baseURL, authToken: getToken() ?? "")
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentContentSetting(feed: FeedItem?) {
        guard let feed = feed else { return }
        let viewModel = ContentSettingViewModel(network: DIContainer.shared.apiDataTransferService)
        let vc = ContentSettingViewController(feed: feed, viewModel: viewModel)
        viewModel.delegate = vc
        vc.modalPresentationStyle = .overFullScreen
        vc.handleOnDismiss = { [weak self] in
            guard let self = self else { return }
            self.controller?.resume()
        }
        controller?.present(vc, animated: false)
    }
    
    func presentStories(feedItems: [FeedItem]) {
        guard feedItems.count > 0 else { return }
        
        let stories = toStories(feedItems: feedItems)
        
        let vc = StoryPreviewController(stories: stories, handPickedStoryIndex: 0)
        vc.modalPresentationStyle = .overFullScreen
//        vc.handleOnDismiss = { [weak self] in
//            guard let self = self else { return }
//            self.controller?.resume()
//        }
        controller?.present(vc, animated: false)
    }

    
    func toStories(feedItems: [FeedItem]) -> [StoriesItem] {
        var stories = [StoriesItem]()
        feedItems.forEach { feedItem in
            
            var typeMedia = "image"
            var urlMedia = feedItem.coverPictureUrl
            var durationMedia = 4.0
            
            if feedItem.videoUrl.hasSuffix(".mp4") || feedItem.videoUrl.hasSuffix(".m3u8")  {
                typeMedia = "video"
                urlMedia = feedItem.videoUrl
                durationMedia = Double(feedItem.duration) ?? durationMedia
            }
            
            let mediaStory = MediasStory(  id: "",
                                            url: urlMedia,
                                            type: typeMedia,
                                            thumbnail: nil,
                                            metadata: Metadata(width: "576", height: "1024", size: "100", duration: durationMedia),
                                            hlsUrl: "",
                                            isHlsReady: false)

            let storyItem = StoryItem(id: "", medias: [mediaStory], products: [], createAt: 12233333)
            var storyItems = StoriesItem(id: "", stories: [storyItem], account: nil, isBadgeActive: false)
            
            stories.append(storyItems)
        }
        
        return stories
    }
    
    func presentBookmark(feed: FeedItem?) {
        let vc = CustomPopUpViewController(
            title: "Fitur sedang dalam proses pengembangan.",
            description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
            iconImage: UIImage(named: "img_in_progress"),
            iconHeight: 99
        )
        vc.delegate = self
        controller?.present(vc, animated: false)
    }

    func presentDonateStuff(feed: FeedItem?) {
        controller?.pauseIfNeeded()
        onClickDonationCard(item: feed)
    }
    
    func presentSingleFeed(feedId: String) {
        let vc = HotNewsFactory.createSingleFeed(selectedFeedId: feedId)
        vc.bindNavigationBar("")
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HotNewsFactoryRouter {
    
    func onClickCardProduct(feed: FeedItem?) {
        let account = feed?.account.map ({ account in
            Profile(accountType: nil, bio: nil, email: nil, isFollow: nil, birthDate: nil, note: nil, isDisabled: nil, isSeleb: nil, isVerified: nil, mobile: nil, name: nil, photo: nil, username: nil, isSeller: nil, socialMedias: nil, donationBadge: nil, referralCode: nil, urlBadge: nil, isShowBadge: nil, chatPrice: 0)
        })
        
        let medias = feed?.post?.product?.medias?.map ({
            Medias(id: $0.id, type: $0.type, url: $0.url, isHlsReady: nil, hlsUrl: nil,
                   thumbnail: $0.thumbnail.map { KipasKipas.Thumbnail(large: $0.large, medium: $0.medium, small: $0.small)},
                   metadata: nil)
        })
        
        let measurement = feed?.post?.product?.measurement.map {
            ProductMeasurement(weight: $0.weight, length: $0.length, height: $0.height, width: $0.width)
        }
        
        let tempProduct = feed?.post?.product
        let product = Product(accountId: tempProduct?.accountId, postProductDescription: tempProduct?.description, generalStatus: tempProduct?.generalStatus, id: tempProduct?.id, isDeleted: tempProduct?.isDeleted, measurement: measurement, medias: medias, name: tempProduct?.name, price: tempProduct?.price, sellerName: tempProduct?.sellerName, sold: tempProduct?.sold, productPages: tempProduct?.productPages, reasonBanned: tempProduct?.reasonBanned)
        
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: product, account: account)
        detailController.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(detailController, animated: true)
    }
    
    
    func onClickEmptyProfile() {
        let emptyController = EmptyUserProfileViewController()
        emptyController.bindNavigationBar("", true)
        emptyController.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(emptyController, animated: true)
    }
    
    func onClickShortcutStartPaidDM(feed: FeedItem?) {
        guard let account = feed?.account, let userId = account.id, !userId.isEmpty else {
            DispatchQueue.main.async { Toast.share.show(message: "Error: User not found..") }
            return
        }
        
        let user = TXIMUser(userID: userId, userName: account.name ?? "", faceURL: account.photo ?? "", isVerified: account.isVerified ?? false)
        showIMConversation?(user)
    }
    
    func onClickDonationCategory(categoryId: String, completion: @escaping ((String) -> Void)) {
        let vc = FilterDonationCategoryViewController(selectedId: categoryId)
        vc.delegate = self
        vc.handleDismiss = { [weak self] categoryId in
            guard self != nil else { return }
            completion(categoryId)
        }
        let navigation = PanNavigationViewController(rootViewController: vc)
        controller?.presentPanModal(navigation)
    }
    
    func onClickDonationCard(item: FeedItem?) {
        let vc = DonationDetailViewController(donationId: item?.post?.id ?? "", feedId: item?.id ?? "")
        vc.hidesBottomBarWhenPushed = true
        
        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) {
            self.controller?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onClickProfile(with username: String, _ updateFollowStatus: ((Bool) -> Void)? = nil) {
        let vc = ProfileRouter.create(userId: "")
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onClickNewsPortal(url: String, onDismiss: @escaping (() -> Void)) {
        let browserController = FeedCleepOpenBrowserController(url: url)
        browserController.bindNavigationRightBar("", false, icon: .get(.iconClose))
        browserController.onDismiss = onDismiss
        
        let navigate = UINavigationController(rootViewController: browserController)
        controller?.present(navigate, animated: true)
    }
    
    func onClickProfile(id: String, type: String, _ updateFollowStatus: ((Bool) -> Void)? = nil) {
//        if let nav = controller?.navigationController {
//            let controllers = nav.viewControllers
//            let index = controllers.count - 1
//            if let vc = controllers[safe: index - 1] as? ProfileViewController, vc.interactor.userId == id {
//                controller?.navigationController?.popViewController(animated: true)
//                return
//            }
//        }
        
        showProfile?(id)
//        let vc = ProfileRouter.create(userId: id)
//        vc.bindNavigationBar("", icon: "ic_chevron_left_outline_black", customSize: .init(width: 20, height: 14), contentHorizontalAlignment: .fill, contentVerticalAlignment: .fill)
//        vc.hidesBottomBarWhenPushed = true
//        vc.isFromFollowingTab = feedType == .following
//        vc.handleUpdateFollowTabAtHome = { [weak self] in
//            guard let self = self else { return }
//            self.controller?.pullToRefresh()
//            
//        }
//        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onClickHashtag(hashtag: String, selectedFeedId: String) {
        let hashtagVC = HashtagViewController(hashtag: hashtag, selectedFeedId: selectedFeedId)
        hashtagVC.handleUpdateSelectedFeed = { feed in
            NotificationCenter.default.post(
                name: Notification.Name("handleUpdateHotNewsCellLikesFromProfileFeed"),
                object: nil,
                userInfo: [
                    "postId": feed.post?.id ?? "",
                    "feedId": feed.id ?? "",
                    "accountId": feed.account?.id ?? "",
                    "likes": feed.likes ?? 0,
                    "isLike": feed.isLike ?? false,
                    "comments": feed.comments ?? 0
                ]
            )
        }
        hashtagVC.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(hashtagVC, animated: true)
    }
    
    func onClickShare(item: FeedItem?) {
        let isDonation = item?.typePost == "donation"
        let type: CustomShareItemType = isDonation ? .donation : .content
        let path = isDonation ? "donation" : "feed"
        let id = item?.id
        
        let text =  "\(item?.account?.name ?? "KIPASKIPAS") \n\n\(item?.post?.description ?? "") \n\n\nKlik link berikut untuk membuka tautan: \(APIConstants.webURL)/\(path)/\((isDonation ? item?.post?.id : item?.id) ?? "")"
//        let url = item?.post?.medias?.first?.url ?? ""
        var url = ""
        let mediaWithoutVodUrl = item?.post?.medias?.compactMap({ $0.url }).filter({ $0.hasSuffix(".mp4") }).first ?? ""
        
        switch item?.feedType {
        case .donation, .hotNews:
            url = mediaWithoutVodUrl
        case .feed:
            guard let mediaType = item?.feedMediaType else {
                url = item?.post?.medias?.first?.url ?? ""
                return
            }
            
            if mediaType == .image {
                url = item?.post?.medias?.first?.thumbnail?.large ?? ""
            } else {
                url = mediaWithoutVodUrl
            }
            
        default:
            url = item?.post?.medias?.first?.url ?? ""
        }
        
        let accountId = item?.account?.id ?? ""
        let shareItem = CustomShareItem(id: id, message: text, type: type, assetUrl: url, accountId: accountId, name: item?.post?.title, username: item?.account?.username)
        let vc = KKShareController(mainView: KKShareView(), item: shareItem, showAddToStory: item?.account?.id == getIdUser(), showRepost: true)
//        CustomShareViewController(item: item)
        
        vc.onClickReport = { [weak self] in
            self?.controller?.pauseIfNeeded()
        }
        vc.onAddToStory = {
            guard let item = item, let media = item.post?.medias?.first else { return }
            showAddStoryFromFeed?(
                StoryFromFeedParam(
                    url: media.url ?? "",
                    type: media.type == "video" ? .video : .photo,
                    feedId: item.id ?? "",
                    username: item.account?.username ?? ""
                )
            )
        }
        vc.onRepost = { [weak self] in
            guard let self = self else { return }
            let vc = CustomPopUpViewController(
                title: "Fitur sedang dalam proses pengembangan.",
                description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
                iconImage: UIImage(named: "img_in_progress"),
                iconHeight: 99
            )
            vc.delegate = self
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.controller?.present(vc, animated: false)
        }
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: true, completion: nil)
    }
}

// MARK: - Donation Cart Handler
extension HotNewsFactoryRouter {
    func showInputAmountDonation(from feed: FeedItem) {
        let vc = DonationInputAmountViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.handleCreateOrderDonation = { [weak self] amount in
            guard self != nil else { return }
            
            DonationCartManager.instance.add(
                DonationCart(
                    id: feed.id ?? "",
                    title: feed.post?.title ?? "",
                    accountId: feed.account?.id ?? "",
                    accountName: feed.account?.name ?? "",
                    amount: amount
                )
            )
        }
        controller?.present(vc, animated: true) {
            vc.donationType = .add
        }
    }
    
    func showCartDonation() {
        showDonationCart?()
    }
}

extension HotNewsFactoryRouter: FilterDonationSelectionDelegate {
    func filterBy(provinceId: String?) {
        guard feedType == .donation else { return }
        controller?.requestDonationByProvince(id: provinceId)
    }
    
    func filterBy(longitude: Double?, latitude: Double?) {
        guard feedType == .donation else { return }
        controller?.requestDonationBylocation(latitude: latitude, longitude: longitude)
    }
    
    func filterByAllLocation() {
        guard feedType == .donation else { return }
        controller?.requestDonationAll()
    }
}

// MARK: - Story
extension HotNewsFactoryRouter {
    func presentMyStory(
        item: StoryFeed,
        data: KipasKipasStory.StoryData,
        otherStories: [StoryFeed]
    ) {
        let selectedId = item.id ?? ""
        let myStories = data.myStories().toViewModels(.me)
        let friendStories = otherStories.toViewModels(.friends)
        let stories = myStories + friendStories
        
        if !myStories.isEmpty {
            showViewingListStory?(selectedId, stories)
        } else {
            showAddStoryFromLibrary?()
        }
    }
    
    func presentStoryLive() {
        // Do present live
    }
    
    func presentOtherStory(
        item: StoryFeed,
        data: KipasKipasStory.StoryData,
        otherStories: [StoryFeed]
    ) {
        let selectedId = item.id ?? ""
        let myStories = data.myStories().toViewModels(.me)
        let friendStories = otherStories.toViewModels(.friends)
        let stories = myStories + friendStories
        
        showViewingListStory?(selectedId, stories)
    }
    
    func storyDidAdd() {
        showAddStoryFromLibrary?()
    }
    
    func storyDidRetry() {
        retryStoryUpload?()
    }
    
    func storyUploadProgress() -> Double? {
        KipasKipas.storyUploadProgress?()
    }
    
    func storyOnUpload() -> Bool? {
        KipasKipas.storyOnUpload?()
    }
    
    func storyOnError() -> Bool? {
        KipasKipas.storyOnError?()
    }
}

// MARK: - Helper
private extension HotNewsFactoryRouter {
    private func navController() -> UINavigationController? {
        if let controller = self.controller?.navigationController {
            return controller
        }
        
        return (UIApplication.shared.delegate as? AppDelegate)?.window?.topNavigationController
    }
}


class MyCurrencyInfo {
    
    static let shared = MyCurrencyInfo()
    
    var coin: Int = 0
    var diamond: Int = 0
    private var isLoadMyCurrency = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { !self.isLoadMyCurrency ? KKLoading.shared.hide() : KKLoading.shared.show() }
        }
    }
    
    func requestMyCoin(completion: @escaping ((RemoteCurrencyInfoData?, Error?) -> Void)) {
        
        guard AUTH.isLogin() else { return }
        guard !isLoadMyCurrency else { return }
        
        isLoadMyCurrency = true
        
        let endpoint: Endpoint<RemoteCurrencyInfo?> = Endpoint(
            path: "balance/currency/info",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"]
        )
        
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoadMyCurrency = false
            
            switch result {
            case .failure(let error):
                print("Error: Failed to get my coin - \(error.message)")
                completion(nil, error)
            case .success(let response):
                self.coin = response?.data?.coinAmount ?? 0
                self.diamond = response?.data?.diamondAmount ?? 0
                KKCache.common.save(integer: response?.data?.coinAmount ?? 0, key: .coin)
                KKCache.common.save(integer: response?.data?.diamondAmount ?? 0, key: .diamond)
                completion(response?.data, nil)
            }
        }
    }
}

extension HotNewsFactoryRouter: CustomPopUpViewControllerDelegate {
    func didSelectOK() {
        NotificationCenter.default.post(name: .shouldResumePlayer, object: nil)
    }
}
