//
//  FeedRouter.swift
//  KipasKipas
//
//  Created by PT.Koanba on 17/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import FeedCleeps
import UIKit
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import KipasKipasShared

class FeedRouter: FeedCleepsRouter {
    func detailPost(userId: String, item: FeedCleeps.Feed) {
        
        var validFeed: [Feed] = []
        validFeed.append(FeedItemMapper.map(feed: item))
        
        let profileDetail = FeedFactory.createFeedProfileController(requestedPage: 0, totalPage: 0, feed: validFeed, userID: userId, type: .profile(isSelf: false), showBottomCommentSectionView: true)
        profileDetail.bindNavigationBar("" , true, icon: .get(.arrowLeftWhite))

        controller?.navigationController?.displayShadowToNavBar(status: false)
        controller?.navigationController?.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(profileDetail, animated: true)
    }
    
    
    weak var controller: FeedCleepsViewController?
    private let onClickLike: ((Feed) -> Void)?
    private let onClickComment: ((IndexPath, Int) -> Void)?
    private var timestampStorage: TimestampStorage = TimestampStorage()
    
    init(controller: FeedCleepsViewController, onClickLike: ((Feed) -> Void)? = nil, onClickComment: ((IndexPath, Int) -> Void)? = nil) {
        self.controller = controller
        self.onClickLike = onClickLike
        self.onClickComment = onClickComment
    }
    
    func onClickShare(item: FeedCleeps.Feed?) {
        let isDonation = item?.typePost == "donation"
        let type: CustomShareItemType = isDonation ? .donation : .content
        let path = isDonation ? "donation" : "feed"
        let id = item?.id
        
        let text =  "\(item?.account?.name ?? "KIPASKIPAS") \n\n\(item?.post?.postDescription ?? "") \n\n\nKlik link berikut untuk membuka tautan: \(APIConstants.webURL)/\(path)/\(id ?? "")"
        guard let url = item?.post?.medias?.first?.url, let accountId = item?.account?.id else { return }
        let item = CustomShareItem(id: id, message: text, type: type, assetUrl: url, accountId: accountId, name: item?.post?.title, username: item?.account?.username)
        let vc = KKShareController(mainView: KKShareView(), item: item)
        controller?.present(vc, animated: true, completion: nil)
    }
    
    func onShowReportPopUp() {
        let reportPVC = ReportPopupViewController(mainView: ReportPopupView())
        
        reportPVC.modalPresentationStyle = .overFullScreen
        reportPVC.mainView.onBackPressed = {
            reportPVC.dismiss(animated: true)
        }
        controller?.present(reportPVC, animated: true, completion: nil)
    }
    
    func onClickProfile(id: String, type: String, _ updateFollowStatus: ((Bool) -> Void)? = nil) {

//        let anotherUserProfileVC =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id, type: type))
//        anotherUserProfileVC.setProfile(id: id, type: type)
//        anotherUserProfileVC.bindNavigationBar("", true)
//        anotherUserProfileVC.callbackUpdateFollowStatus = updateFollowStatus
//        anotherUserProfileVC.fromHome = true
//        anotherUserProfileVC.hidesBottomBarWhenPushed = true

        let anotherUserProfileVC = ProfileRouter.create(userId: id)
        anotherUserProfileVC.bindNavigationBar("", icon: "ic_chevron_left_outline_black", customSize: .init(width: 20, height: 14), contentHorizontalAlignment: .fill, contentVerticalAlignment: .fill)
        anotherUserProfileVC.hidesBottomBarWhenPushed = true
        anotherUserProfileVC.isFromFollowingTab = false

        controller?.navigationController?.pushViewController(anotherUserProfileVC, animated: true)
    }
    
    func onClickProfile(with username: String, _ updateFollowStatus: ((Bool) -> Void)? = nil) {
        let anotherUserProfileVC =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource())
        anotherUserProfileVC.username = username
        anotherUserProfileVC.bindNavigationBar("", true)
        anotherUserProfileVC.callbackUpdateFollowStatus = updateFollowStatus
        anotherUserProfileVC.fromHome = true
        anotherUserProfileVC.hidesBottomBarWhenPushed = true
        
        controller?.navigationController?.pushViewController(anotherUserProfileVC, animated: true)
    }
    
    func onClickHashtag(hashtag: String) {
        let hashtagVC = HashtagViewController(hashtag: hashtag)
        hashtagVC.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(hashtagVC, animated: true)
    }
    
    func onShowAuthPopUp(onDismiss: @escaping (() -> Void)) {
        let popup = AuthPopUpViewController(mainView: AuthPopUpView())
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        popup.handleWhenNotLogin = {
            popup.dismiss(animated: true, completion: nil)
            onDismiss()
        }
        controller?.present(popup, animated: true, completion: nil)
    }
    
    func navigateToPurchaseCoin() {
        let vc = CoinPurchaseRouter.create(baseUrl: APIConstants.baseURL, authToken: getToken() ?? "")
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentShortcutStartPaidDM(userId: String?, name: String?, avatar: String?, isVerified: Bool?) {
        guard AUTH.isLogin() else {
            onShowAuthPopUp {}
            return
        }
        
        MyCurrencyInfo.shared.requestMyCoin { [weak self] currency, error in
            guard currency?.coinAmount ?? 0 >= 5 else {
                self?.controller?.presentKKPopUpView(
                    title: "Yah koin yang kamu punya tidak cukup untuk memulai sesi pesan berbayar",
                    message: "Beli Koin kipaskipas untuk memulai sesi berbayar",
                    imageName: "imageSad",
                    cancelButtonTitle: "Kirim Pesan Biasa",
                    actionButtonTitle: "Beli Koin Kipaskipas",
                    onActionTap: { [weak self] in
                        self?.navigateToPurchaseCoin()
                    },
                    onCancelTap: { [weak self] in
                        self?.onClickShortcutStartPaidDM(userId: userId, name: name, avatar: avatar, isVerified: isVerified)
                    },
                    onCloseTap: { [weak self] in
                        self?.controller?.playVisibleCell()
                    }
                )
                return
            }
            
            self?.onClickShortcutStartPaidDM(userId: userId, name: name, avatar: avatar, isVerified: isVerified)
        }
    }
    
    func onClickShortcutStartPaidDM(userId: String?, name: String?, avatar: String?, isVerified: Bool?) {
        guard let userId = userId else {
            return
        }
        let user = TXIMUser(userID: userId, userName: name ?? "", faceURL: avatar ?? "", isVerified: isVerified ?? false)
        showIMConversation?(user)
    }
    
    func onClickComment(id: String, item: FeedCleeps.Feed, indexPath: IndexPath, autoFocusToField: Bool, identifier: String) {
        let commentVc = CommentHalftController(postId: id, postAccountId: item.account?.id ?? "", postAccountIsVerified: item.account?.isVerified ?? false, identifier: item.typePost == "donation" ? "DONATION" : identifier, chatPrice: item.account?.chatPrice ?? 1)
        commentVc.commentCountCallback = { [controller, onClickComment] count in
            controller?.handleUpdateSelectedFeedComment(at: indexPath, count: count)
            onClickComment?(indexPath, count)
        }
        
        commentVc.handleClickUser = { [weak self ]id, type in
            guard let self = self else { return }
            self.onClickProfile(id: id, type: type)
        }
        
        commentVc.handleClickHashtag = { [weak self] hashtag in
            guard let self = self else { return }
            self.onClickHashtag(hashtag: hashtag)
        }
        
        commentVc.handleEmptyProfile = { [weak self] in
            self?.onClickEmptyProfile()
        }
        
        commentVc.handleStartPaidDM = { [weak self] in
            commentVc.dismiss(animated: false) {
                self?.onStartPaidMessage(userId: item.account?.id, name: item.account?.name, avatar: item.account?.photo, isVerified: item.account?.isVerified)
            }
        }
        
        if autoFocusToField {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                commentVc.router.navigateToCustomCommentInput(attributedText: commentVc.mainView.commentInputView.textView.attributedText, followings: [], isAutoMention: false)
            }
        }
        
        let nav = UINavigationController(rootViewController: commentVc)
        nav.modalPresentationStyle = .overFullScreen
        controller?.present(nav, animated: false)
    }
    
    func onClickProductDetail(id: String, product: FeedCleeps.Product, item: FeedCleeps.Feed) {
        let account = FeedItemMapper.map(feed: item).account
        
        let medias = product.medias?.map { KipasKipas.Medias(id: $0.id, type: $0.type, url: $0.url, isHlsReady: $0.isHlsReady, hlsUrl: $0.hlsUrl, thumbnail: $0.thumbnail.map { KipasKipas.Thumbnail(large: $0.large, medium: $0.medium, small: $0.small)}, metadata: $0.metadata.map { KipasKipas.Metadata(width: $0.width, height: $0.height, size: $0.size, duration: $0.duration) } ) }
        
        let measurement = product.measurement.map {
            KipasKipas.ProductMeasurement(weight: $0.weight, length: $0.length, height: $0.height, width: $0.width)
        }
        
        let product = KipasKipas.Product(accountId: product.accountId, postProductDescription: product.postProductDescription, generalStatus: product.generalStatus, id: product.id, isDeleted: product.isDeleted, measurement: measurement, medias: medias, name: product.name, price: product.price, sellerName: product.sellerName, sold: product.sold, productPages: product.productPages, reasonBanned: product.reasonBanned)
        
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: product, account: account)
        detailController.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(detailController, animated: true)
    }
    
    func onClickLogin() {
        controller?.view.window?.rootViewController?.dismiss(animated: false, completion: {
            NotificationCenter.default.post(name: .showOnboardingView, object: nil, userInfo: [:])
        })
    }
    
    func onClickEmptyProfile() {
        let emptyController = EmptyUserProfileViewController()
        emptyController.bindNavigationBar("", true)
        emptyController.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(emptyController, animated: true)
    }
    
    func onClickProductBg(item: FeedCleeps.Feed) {
        var dataSource = AnotherProductModel.DataSource()
        dataSource.id = item.account?.id ?? ""
        let feed = FeedItemMapper.map(feed: item)
        guard let controller = controller else { return }
        ProductSheetFactory.show(from: controller, feed: feed, products: [ProductItem.fromProduct(feed.post!.product!)], delegate: self)
    }
    
    func onClickLike(item: FeedCleeps.Feed) {
        onClickLike?(FeedItemMapper.map(feed: item))
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
    
    func onClickDonationCard(item: FeedCleeps.Feed) {
        let vc = DonationDetailViewController(donationId: item.post?.id ?? "", feedId: item.id ?? "")
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func onClickFloatingLink(url: String) {
//        let vc = CustomPopUpViewController(title: "Apa kamu yakin akan membuka link ini?", description: url, okBtnTitle: "Ya, buka link", isHideIcon: true)
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overFullScreen
//        controller?.present(vc, animated: true)
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
//        vc.mainStackView.layoutMargins = UIEdgeInsets(top: 30, left: 20, bottom: 24, right: 20)
//        vc.mainStackView.spacing = 20
//        vc.textStackView.spacing = 8
//        
//        vc.actionStackView.spacing = 8
//        vc.cancelButton.isHidden = false
//        vc.cancelButton.text("Tidak")
//        vc.okButton.backgroundColor = .primary
//        vc.handleTapOKButton = { [weak self] in
//            guard let self = self else { return }
            let vc = FloatingLinkWebViewController(url)
            vc.hidesBottomBarWhenPushed = true
            self.controller?.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func onClickNewsPortal(url: String, onDismiss: @escaping (() -> Void)) {
        let browserController = FeedCleepOpenBrowserController(url: url)
        browserController.bindNavigationRightBar("", false, icon: .get(.iconClose))
        browserController.onDismiss = onDismiss
        
        let navigate = UINavigationController(rootViewController: browserController)
        self.controller?.present(navigate, animated: true)
    }
    
    func onStartPaidMessage(userId: String?, name: String?, avatar: String?, isVerified: Bool?) {
        struct Root: Codable {
            let code: String?
            let message: String?
        }
        
        guard let userId else {
            return
        }
        
        let channelURL = [getIdUser(), userId].sorted().joined(separator: "_")
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "chat/register-account",
            method: .post,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            bodyParamaters: [
                "externalChannelId": channelURL,
                "payerId": getIdUser(),
                "recipientId": userId
            ]
        )
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(_):
                DispatchQueue.main.async { Toast.share.show(message: "Failed to start message, please try again..") }
            case .success(_):
                self.presentShortcutStartPaidDM(userId: userId, name: name, avatar: avatar, isVerified: isVerified)
            }
        }
    }
}

// MARK: Addition router func
extension FeedRouter {
    func handleOnClickShare(_ feed: FeedCleeps.Feed, view vc: FeedCleepsViewController, product: Product? = nil) {
        let text =  "\(feed.account?.name ?? "KIPASKIPAS") \n\n\(feed.post?.postDescription ?? "") \n\n\nKlik link berikut untuk membuka tautan: \(APIConstants.webURL)/shop/\(product?.id ?? "")"
        guard let id = product?.id, let url =  product?.medias?.first?.thumbnail?.medium, let name = product?.name, let accountId = feed.account?.id else { return }
        let item = CustomShareItem(id: id,message: text, type: .shop, assetUrl: url, accountId: accountId, name: name, price: product?.price, username: feed.account?.username)
        let controller = KKShareController(mainView: KKShareView(), item: item)
        vc.present(controller, animated: true, completion: nil)
    }
    
    func handleOnClickProductDetail(product: KipasKipas.Product, view vc: FeedCleepsViewController, account: KipasKipas.Profile?) {
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: product, account: account)
        detailController.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(detailController, animated: true)
    }
}

extension FeedRouter: ProductSheetDelegate {
    func onShop(_ feed: Feed) {
        let isLogin = getToken() != nil ? true : false
        guard let controller = controller else { return }
        
        guard isLogin else {
            self.onShowAuthPopUp {}
            return
        }
        
        let storeController = AnotherProductFactory.createAnotherProductController(account: feed.account!)
        storeController.bindNavigationBar(.get(.shopping), true)
        storeController.hidesBottomBarWhenPushed = true
        controller.navigationController?.pushViewController(storeController, animated: true)
    }
    
    func onMessage(_ product: ProductItem, _ feed: Feed) {
        let isLogin = getToken() != nil ? true : false
        guard let controller = controller else { return }
        
        if !isLogin {
            self.onShowAuthPopUp(){}
        } else {
            guard let account = FeedItemMapper.map(feed: feed).account, let product = FeedItemMapper.map(feed: feed).post?.product else { return }
            self.routeToDM(account: account, product: product, vc: controller)
        }
    }
    
    func onShare(_ product: ProductItem, _ feed: Feed) {
        guard let controller = controller else { return }
        handleOnClickShare(FeedItemMapper.map(feed: feed), view: controller, product: product.toProduct())
    }
    
    func onBuy(_ product: ProductItem, _ feed: Feed) {
        guard let controller = controller else { return }
        handleOnClickProductDetail(product: product.toProduct(), view: controller, account: feed.account)
    }
    
    func onPlayVideo(_ product: ProductItem) {
        guard let controller = self.controller, let medias = product.toProduct().medias else { return }
        let vc = MediaDetailViewController(medias: medias, selectedMediaIndex: 0, isPlayVideo: true)
        vc.bindNavigationBar()
        vc.hidesBottomBarWhenPushed = true
        controller.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeedRouter: FilterDonationSelectionDelegate {
    func filterBy(provinceId: String?) {
        controller?.filterBy(provinceId: provinceId)
    }
    
    func filterBy(longitude: Double?, latitude: Double?) {
        controller?.filterByCoordinate(longitude: longitude, latitude: latitude)
    }
    
    func filterByAllLocation() {
        controller?.filterByAllLocation()
    }
}

// MARK: DM
extension FeedRouter {
    func routeToDM(account: FeedCleeps.Profile, product: FeedCleeps.Product, vc: FeedCleepsViewController) {
        
        struct Root: Codable {
            let code: String?
            let message: String?
        }
        
        let channelURL = [getIdUser(), account.id ?? ""].sorted().joined(separator: "_")
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "chat/register-account",
            method: .post,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            bodyParamaters: [
                "externalChannelId": channelURL,
                "payerId": getIdUser(),
                "recipientId": account.id ?? ""
            ]
        )
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(_):
                DispatchQueue.main.async { Toast.share.show(message: "Failed to start message, please try again..") }
            case .success(_):
                self.createConversation(userId: account.id, userName: account.name, faceURL: account.photo, isVerified: account.isVerified)
            }
        }
    }
    
    private func createConversation(userId: String?, userName: String?, faceURL: String?, isVerified: Bool?) {
        guard let controller = controller else { return }
        
        guard let userId = userId, !userId.isEmpty else {
            DispatchQueue.main.async { Toast.share.show(message: "Error: User not found..") }
            return
        }
        
        let user = TXIMUser(userID: userId, userName: userName ?? "", faceURL: faceURL ?? "", isVerified: isVerified ?? false)
        showIMConversation?(user)
    }
    
    func onNavigateToChannel(channelUrl: String, vc: FeedCleepsViewController) {
        print("route to DM channel")
    }
    
    func routeToFakeDM(account: FeedCleeps.Profile, vc: FeedCleepsViewController) {
        print("route to fake DM ")
    }
    
    func leaveFakeDM(accountId: String) {
        print("leave to DM ")
    }
}
