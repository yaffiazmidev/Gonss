//
//  ProfileInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 24/12/23.
//

import UIKit
import FeedCleeps
import KipasKipasShared
import KipasKipasDirectMessage
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasDirectMessage

protocol IProfileInteractor: AnyObject {
    var postCurrentPage: Int { get set }
    var postTotalPage: Int { get set }
    var productCurrentPage: Int { get set }
    var productTotalPage: Int { get set }
    var isLoading: Bool { get set }
    var isVerified: Bool { get set }
    var userId: String { get set }
    var username: String { get set }
    
    func requestUserProfile()
    func requestUserProfileMutual()
    func requestUserProfilePost()
    func requestUserProfileUploadPicture(with item: KKMediaItem)
    func requestUserProfileUpdatePicture(by userId: String, with url: String)
    func updateIsFollow(by userId: String, isFollow: Bool)
    func requestProducts()
}

class ProfileInteractor: IProfileInteractor {
    
    private let presenter: IProfilePresenter
    private let loader: ProfileLoader
    var postCurrentPage: Int = 0
    var postTotalPage: Int = 0
    var productCurrentPage: Int = 0
    var productTotalPage: Int = 0
    var isLoading: Bool = false
    var isVerified: Bool = false
    var isMutual: Bool = false
    let uploader: MediaUploader!
    let followUnfollowUpdater: FollowUnfollowUpdater
    let productLoader: ProductListLoader
    var userId: String = ""
    var username: String = ""
    
    private(set) lazy var loggedInUserStore: LoggedUserKeychainStore = {
        let store = LoggedUserKeychainStore(key: .loggedInUser)
        store.needAuth = {
            NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
        }
        return store
    }()
    
    init(
        presenter: IProfilePresenter,
        loader: ProfileLoader,
        followUnfollowUpdater: FollowUnfollowUpdater,
        productLoader: ProductListLoader,
        userId: String,
        username: String
    ) {
        self.presenter = presenter
        self.loader = loader
        self.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
        self.followUnfollowUpdater = followUnfollowUpdater
        self.productLoader = productLoader
        self.userId = userId
        self.username = username
    }
    
    func requestUserProfile() {
        guard userId.isEmpty == false else { return }
        
        loader.data(request: .init(userId: userId)) { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result {
                self.isVerified = response.isVerified ?? false
                if let loginUserId = TXIMUserManger.shared.currentUserId, loginUserId == userId {
                    TXIMUserManger.shared.updateUserInfo(nickName: response.name, profileURL: response.photo, isVerified: isVerified)
                    
                    UserManager.shared.username = response.username
                    UserManager.shared.userAvatarUrl = response.photo
                    UserManager.shared.userVerify = isVerified
                }
                
                let loggedInUser = self.loggedInUserStore.retrieve()
  
                UserDefaults.standard.setValue(response.username, forKey: "username")
                UserDefaults.standard.setValue(response.name, forKey: "name")
                if loggedInUser?.accountId == response.id {
                    let updateLoggedInUser = LoggedInUser(
                        role: loggedInUser?.role ?? "",
                        userName: loggedInUser?.userName ?? "",
                        userEmail: loggedInUser?.userEmail ?? "",
                        userMobile: loggedInUser?.userMobile ?? "",
                        accountId: loggedInUser?.accountId ?? "",
                        photoUrl: response.photo ?? ""
                    )
                    
                    self.loggedInUserStore.insert(updateLoggedInUser)
                }
            }
            self.presenter.presentUserProfile(with: result)
        }
    }
    
    func requestUserProfileMutual(){
        guard userId.isEmpty == false else { return }
        
        loader.mutual(request: .init(targetAccountId: userId)) { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result {
                self.isMutual = response.isMutual 
            }
            self.presenter.presentUserProfileMutual(with: result)
        }
    }
    
    
    func requestUserProfilePost() {
        isLoading = true        
        
        let request = PagedFeedVideoLoaderRequest(
            page: postCurrentPage,
            isPublic: false,
            feedType: .profile,
            profileId: userId
        )
        
        loader.post(request: request) { [weak self] result in
            guard let self = self else { return }
            
            if case .success(let response) = result {
                self.postTotalPage = (response.totalPages ?? 0) - 1
            }
            
            self.presenter.presentUserProfilePost(with: result)
        }
    }
    
    func requestUserProfileUploadPicture(with item: KKMediaItem) {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            presenter.presentUserProfileUploadPicture(with: .failure(KKNetworkError.connectivity))
            return
        }
        
        guard let data = item.data,
              let uiImage = UIImage(data: data),
              let ext = item.path.split(separator: ".").last
        else {
            presenter.presentUserProfileUploadPicture(with: .failure(KKNetworkError.invalidData))
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "\(ext)")
        uploader.upload(request: request) { [weak self] (result) in
            guard let self = self else { return }
            switch result{
            case .success(let response):
                
                let media = ResponseMedia(
                    id: nil,
                    type: "image",
                    url: response.tmpUrl,
                    thumbnail: Thumbnail(large: response.url, medium: response.url, small: response.url),
                    metadata: Metadata(
                        width: "\(uiImage.size.width * uiImage.scale)",
                        height: "\(uiImage.size.height * uiImage.scale)",
                        size: "0"
                    )
                )
                
                self.presenter.presentUserProfileUploadPicture(with: .success(media))
                return
                
            case .failure(let error):
                self.presenter.presentUserProfileUploadPicture(
                    with: .failure(
                        KKNetworkError.responseFailure(
                            KKErrorNetworkResponse(
                                code: "0",
                                message: error.getErrorMessage()
                            )
                        )
                    )
                )
                return
            }
        }
    }
    
    func requestUserProfileUpdatePicture(by userId: String, with url: String) {
        loader.updatePicture(request: .init(userId: userId, pictureUrl: url)) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentUserProfileUpdatePicture(with: result)
        }
    }
    
    func updateIsFollow(by userId: String, isFollow: Bool) {
        followUnfollowUpdater.load(request: .init(id: userId, isFollow: isFollow)) { [weak self] result in
            guard let self = self else { return }
            
            if isFollow == false, case .success(let response) = result {
                self.requestUserProfileMutual()
            }else{
                self.presenter.presentUpdateIsFollow(with: result)
            }
        }
    }
    
    func requestProducts() {
        productLoader.load(
            request: .init(
                accountId: userId,
                page: productCurrentPage,
                type: ProductType.all.rawValue
            )
        ) { [weak self] result in
            guard let self = self else { return }
            
            if case .success(let response) = result {
                self.productTotalPage = response.totalPages - 1
            }
            
            self.presenter.presentProductsEtalse(with: result)
        }
    }
}
