//
//  ProfileRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 24/12/23.
//

import Foundation
import KipasKipasShared
import UIKit
import KipasKipasDirectMessageUI
import KipasKipasDirectMessage
import FeedCleeps

protocol IProfileRouter {
    func presentPictureOptions(image: UIImage?)
    func navigateToMyProduct(isVerified: Bool)
    func navigateToProfileMenu(isVerified: Bool, accountType: String)
    func presentPicturePreview(image: UIImage?, url: String?)
    func presentCamera(onMediaSelected: @escaping ((KKMediaItem) -> Void))
    func presentDonationRankAndBadge(accountId: String)
    func presentLibrary()
    func presentPictureCropper(with item: KKMediaItem)
    func showInProgressDialog()
    func navigateToFollowers(id: String)
    func navigateToFollowings(id: String)
    func navigateToHistoryTransaction()
    func navigateToEditProfile(id: String)
    func navigateToShop(id: String)
    func presentLoginPopUp()
    func navigateToDM(userId: String?, userName: String?, photo: String?, isVerify: Bool)
}

class ProfileRouter: IProfileRouter {
    weak var controller: ProfileViewController?
    
    init(controller: ProfileViewController?) {
        self.controller = controller
    }
    
    func presentPictureOptions(image: UIImage?) {
        let options = ProfilePictureOptionsController()
        options.delegate = controller
        options.image = image
        options.modalPresentationStyle = .overFullScreen
        controller?.present(options, animated: false)
    }
    
    func navigateToMyProduct(isVerified: Bool) {
        let storeController = MyProductFactory.createMyProductController(isVerified)
        storeController.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(storeController, animated: true)
    }
    
    func navigateToProfileMenu(isVerified: Bool, accountType: String) {
        let presentedViewController = ProfileMenuViewController(mainView: ProfileMenuView(), dataSource: ProfileMenuModel.DataSource(id: getIdUser(), showNavBar: false, isVerified: isVerified, accountType: accountType))
        presentedViewController.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(presentedViewController, animated: true)
    }
    
    func presentPicturePreview(image: UIImage?, url: String?) {
        let options = ProfilePicturePreviewController(image: image, url: url)
        options.modalPresentationStyle = .overFullScreen
        controller?.present(options, animated: false)
    }
    
    func presentCamera(onMediaSelected: @escaping ((KKMediaItem) -> Void)) {
        showCameraPhotoViewController?(onMediaSelected)
    }
    
    func presentLibrary() {
        if let controller = controller {
            let picker = KKMediaPicker()
            picker.delegate = controller
            picker.types = [.photo]
            picker.show(in: controller)
        }
    }
    
    func presentDonationRankAndBadge(accountId: String) {
        showDonationRankAndBadge?(accountId)
    }
    
    func presentPictureCropper(with item: KKMediaItem) {
        let vc = ProfilePictureCropController(item: item)
        vc.delegate = controller
        vc.hidesBottomBarWhenPushed = true
        vc.modalPresentationStyle = .fullScreen
        controller?.present(vc, animated: true)
    }
    
    func showInProgressDialog() {
        let vc = CustomPopUpViewController(
            title: "Fitur sedang dalam proses pengembangan.",
            description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
            iconImage: UIImage(named: "img_in_progress"),
            iconHeight: 99
        )
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: false)
    }
    
    func navigateToFollowers(id: String) {
        let dataSource = FollowersModel.DataSource()
        dataSource.id = id
        dataSource.showNavBar = true
        let followers = FollowersController(mainView: FollowersView(), dataSource: dataSource)
        followers.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(followers, animated: false)
    }
    
    func navigateToFollowings(id: String) {
        let dataSource = FollowingsModel.DataSource()
        dataSource.id = id
        dataSource.showNavBar = true
        let followings = FollowingsController(mainView: FollowingsView(), dataSource: dataSource)
        followings.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(followings, animated: false)
    }
    
    func navigateToDM(userId: String?, userName: String?, photo: String?, isVerify: Bool) {
        let timestampStorage: TimestampStorage = TimestampStorage()
        guard let userId = userId, !userId.isEmpty else {
            DispatchQueue.main.async { Toast.share.show(message: "Error: User not found..") }
            return
        }
        
        let user = TXIMUser(userID: userId, userName: userName ?? "", faceURL: photo ?? "", isVerified: false)
        showIMConversation?(user)
    }
    
    func presentHashtag(value: String?) {
        let hashtagVC = HashtagViewController(hashtag: value ?? "")
        hashtagVC.isFromProfile = true
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
    
    func navigateToHistoryTransaction() {
        let vc = StatusTransactionController()
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToEditProfile(id: String) {
        let vc = EditProfileViewController(mainView: EditProfileView(), dataSource: EditProfileModel.DataSource(id: id))
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToShop(id: String) {
        
        if id == getIdUser() {
            let storeController = MyProductFactory.createMyProductController(true)
            storeController.hidesBottomBarWhenPushed = true
            controller?.navigationController?.pushViewController(storeController, animated: true)
        } else {
//            var profile = Profile.emptyObject()
//            profile.id = id
//            let storeController = AnotherProductFactory.createAnotherProductController(account: profile)
//            storeController.hidesBottomBarWhenPushed = true
            
            let storeController = ShopComingSoonController()
            storeController.bindNavigationBar(.get(.shopping), icon: "ic_chevron_left_outline_black")
            controller?.navigationController?.pushViewController(storeController, animated: true)
        }
    }
    
    func presentLoginPopUp() {
        showLogin?()
    }
}

extension ProfileRouter {
    static func create(userId: String = "", username: String = "") -> ProfileViewController {
        let controller = ProfileViewController()
        let router = ProfileRouter(controller: controller)
        let presenter = ProfilePresenter(controller: controller)        
        let client = HTTPClientFactory.makeAuthHTTPClient(timeoutInterval: 10.0)
        let baseURL = URL(string: APIConstants.baseURL)!
        let loader = RemoteProfileLoader(baseUrl: baseURL, client: client)
        
        
        let refreshTokenService: RefreshTokenService = RefreshTokenService()
        let token = getToken() ?? ""
        let followUnfollowUpdater = HardcodeRemoteFollowUnfollowUpdater(
            url: baseURL,
            httpClient: client,
            token: token,
            refreshTokenService: refreshTokenService
        )
        let productLoader = RemoteProductListLoader(url: baseURL, client: client)
        
        let interactor = ProfileInteractor(
            presenter: presenter,
            loader: MainQueueDispatchDecorator(decoratee: loader),
            followUnfollowUpdater: MainQueueDispatchDecorator(decoratee: followUnfollowUpdater), 
            productLoader: MainQueueDispatchDecorator(decoratee: productLoader),
            userId: userId,
            username: username
        )
        
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
}
