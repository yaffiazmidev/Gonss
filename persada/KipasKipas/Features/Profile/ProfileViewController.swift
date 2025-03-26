//
//  ProfileViewController.swift
//  KipasKipasProfileUI
//
//  Created by DENAZMI on 22/12/23.
//

import UIKit
import FeedCleeps
import KipasKipasShared

protocol IProfileViewController: AnyObject {
    func displayUserProfile(data: RemoteUserProfileData?)
    func displayUserProfileMutual(data: RemoteAcountMutualData?)
    func displayUserProfilePosts(contents: [RemoteFeedItemContent])
    func displayUserProfileUploadedPicture(data: ResponseMedia)
    func displayUserProfileUpdatedPicture(data: String)
    func displayError(_ message: String)
    func displayUpdatedIsFollow()
    func displayProductEtalase(products: [ShopViewModel])
    func displayErrorUserProfile()
}

public class ProfileViewController: UIViewController {
    
    private lazy var mainView: ProfileView = {
        let view = ProfileView().loadViewFromNib() as! ProfileView
        view.delegate = self
        return view
    }()
    
    var router: IProfileRouter!
    var interactor: IProfileInteractor!
    let postController = ProfilePostViewController()
//    let showcaseController = ProfileShowcaseViewController()
    let showcaseController = ProfileShowcaseComingSoonController()
    var isFromFollowingTab: Bool = false
    var handleUpdateFollowTabAtHome: (() -> Void)?
    
    var isSelfProfile = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        mainView.userId = interactor.userId
        
        setIsSelfProfile()
//        showcaseController.userId = userId
        setupPageView()
        defaultRequest()
        handleOnTapComponent()
        
        navigationItem.rightBarButtonItems = mainView.rightBarButtonItems()
        NotificationCenter.default.addObserver(self, selector: #selector(onProfileUpdated(notification:)), name: .notificationUpdateProfile, object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = hidesBottomBarWhenPushed || (navigationController?.hidesBottomBarWhenPushed ?? false)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactor.requestUserProfile()
        interactor.requestUserProfileMutual()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isFromFollowingTab && mainView.user?.isFollow == false {
            handleUpdateFollowTabAtHome?()
        }
    }
    
    public override func loadView() {
        view = mainView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupPageView() {
        mainView.pageViewController.delegate = mainView
        mainView.pageViewController.dataSource = mainView
        mainView.viewControllerList = [postController, showcaseController]
        mainView.pageViewController.setViewControllers([mainView.viewControllerList[0]], direction: .reverse, animated: true, completion: nil)
        mainView.selectedTabMenu = .post
        
        mainView.menuContainerView.insertSubview(mainView.pageViewController.view, at: 0)
        addChild(mainView.pageViewController)
        mainView.pageViewController.didMove(toParent: self)
        
        mainView.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainView.pageViewController.view.topAnchor.constraint(equalTo: mainView.menuContainerView.topAnchor, constant: 0),
            mainView.pageViewController.view.bottomAnchor.constraint(equalTo: mainView.menuContainerView.bottomAnchor),
            mainView.pageViewController.view.leadingAnchor.constraint(equalTo: mainView.menuContainerView.leadingAnchor),
            mainView.pageViewController.view.trailingAnchor.constraint(equalTo: mainView.menuContainerView.trailingAnchor)
        ])
        
        view.layoutIfNeeded()
        
        for v in mainView.pageViewController.view.subviews {
            if v.isKind(of: UIScrollView.self) {
                (v as! UIScrollView).delegate = mainView
            }
        }
    }
    
    func defaultRequest() {
//        interactor.requestUserProfile(by: userId)
        interactor.requestUserProfileMutual()
        
        interactor.postCurrentPage = 0
        interactor.postTotalPage = 0
        interactor.requestUserProfilePost()
    }
    
    private func requestProducts() {
        interactor.productCurrentPage = 0
        interactor.productTotalPage = 0
        interactor.requestProducts()
    }
    
    @objc func onProfileUpdated(notification: NSNotification?) {
        if(self.isSelfProfile) {
            if let loginId = UserDefaults.standard.string(forKey: "USER_LOGIN_ID") {
                //case PE-14255
                interactor.userId = loginId
            }
            defaultRequest()
        }
    }
    
    
    private func setIsSelfProfile() {
        //case PE-14354
        if let loginId = UserDefaults.standard.string(forKey: "USER_LOGIN_ID") {
            if(loginId == interactor.userId) {
                self.isSelfProfile = true
            }
        }
    }

}

extension ProfileViewController {
    private func handleOnTapComponent() {
        mainView.editProfileContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.router.navigateToEditProfile(id: self.interactor.userId)
        }
        
        mainView.showcaseButtonContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.router.navigateToShop(id: self.interactor.userId)
        }
        
        mainView.followContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            guard getToken() != nil else {
                self.router.presentLoginPopUp()
                return
            }
            guard let isFollow = self.mainView.user?.isFollow else { return }
            self.updateIsFollowStatus(by: self.mainView.user, isFollow: true)
            self.interactor.updateIsFollow(by: self.interactor.userId, isFollow: isFollow)
        }
        
        mainView.alreadyFollowContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            guard let isFollow = self.mainView.user?.isFollow else { return }
            self.updateIsFollowStatus(by: self.mainView.user, isFollow: false)
            self.interactor.updateIsFollow(by: self.interactor.userId, isFollow: isFollow)
        }
    }
    
    func updateIsFollowStatus(by user: RemoteUserProfileData?, isFollow: Bool) {
        let data: [String : Any] = [
            "accountId" : user?.id ?? "",
            "isFollow": isFollow,
            "name": user?.name ?? "",
            "photo": user?.photo ?? ""
        ]
        
        mainView.user?.isFollow = isFollow
        let totalFollowers = mainView.user?.totalFollowers ?? 0
        mainView.user?.totalFollowers = isFollow ? totalFollowers + 1 : totalFollowers - 1
        mainView.user = mainView.user
        postController.user = mainView.user
        NotificationCenter.default.post(name: .updateIsFollowFromFolowingFolower, object: nil, userInfo: data)
    }
}

extension ProfileViewController: IProfileViewController {
    
    func displayErrorUserProfile() {
        mainView.contentContainerStackView.isHidden = true
        mainView.addYoursStackView.isHidden = true
        mainView.verifiedIconImageView.isHidden = true
        mainView.badgeStackView.isHidden = true
        mainView.shareButton.isHidden = true
        
        mainView.user = nil
        mainView.titleLabel.text = ""
        navigationItem.titleView = nil
        mainView.usernameLabel.text = "User tidak ditemukan"
        mainView.badgedProfileImageView.userImageView.image = UIImage(named: "iconProfilePlaceholder")
    }
    
    func displayUserProfile(data: RemoteUserProfileData?) {
        guard let user = data else {
            mainView.contentContainerStackView.isHidden = true
            mainView.addYoursStackView.isHidden = true
            mainView.verifiedIconImageView.isHidden = true
            mainView.badgeStackView.isHidden = true
            mainView.shareButton.isHidden = true
            mainView.messageContainerStackView.isHidden = true
            mainView.followContainerStackView.isHidden = true
            
            mainView.user = nil
            mainView.titleLabel.text = ""
            navigationItem.titleView = nil
            mainView.usernameLabel.text = "User tidak ditemukan"
            mainView.badgedProfileImageView.userImageView.image = UIImage(named: "iconProfilePlaceholder")
            return
        }
        
        interactor.requestUserProfileMutual()
        requestProducts()
        
        mainView.shareButton.isHidden = false
        mainView.verifiedIconImageView.isHidden = false
        mainView.badgeStackView.isHidden = false
        mainView.contentContainerStackView.isHidden = false
        mainView.addYoursStackView.isHidden = false
        mainView.titleLabel.text = (user.name ?? "").trimFullName(limit: 20)
        mainView.titleLabel.sizeToFit()
        navigationItem.titleView = self.mainView.titleLabel
        navigationItem.titleView?.layoutIfNeeded()
        print("[DENAZMI] ", mainView.user?.isFollow, user.isFollow)
        
        if let lastedFollow = mainView.user?.isFollow {
            if lastedFollow == user.isFollow {
                mainView.user = user
            } else {
                var lastUpdateData = user
                lastUpdateData.isFollow = mainView.user?.isFollow
                mainView.user = lastUpdateData
            }
        } else {
            mainView.user = user
        }
        
        postController.user = user
    }
     
    
    func displayUserProfileMutual(data: RemoteAcountMutualData?){
        let imgName = (data?.isMutual ?? false) ?  "ic_user_checked_solid_mutual" : "ic_user_checked_solid_black"
        mainView.followIconImage.image = UIImage(named: imgName)
//        self.updateIsFollowStatus(by: self.mainView.user, isFollow: true)
    }
    
    func displayUserProfilePosts(contents: [RemoteFeedItemContent]) {
        postController.currentPage = interactor.postCurrentPage
        if mainView.selectedTabMenu == .post {
            if interactor.postCurrentPage <= 0 {
                mainView.posts = contents
                postController.posts = contents
            } else {
                mainView.posts.append(contentsOf: contents)
                postController.posts.append(contentsOf: contents)
            }
        }
        
        interactor.isLoading = false
        mainView.refreshControl.endRefreshing()
    }
    
    func displayUserProfileUploadedPicture(data: ResponseMedia) {
        KKLoading.shared.hide()
        if let url = data.url {
            interactor.requestUserProfileUpdatePicture(by: interactor.userId, with: url)
            KKLoading.shared.show()
        }
    }
    
    func displayUserProfileUpdatedPicture(data: String) {
        KKLoading.shared.hide()
        didRefreshPage()
    }
    
    func displayError(_ message: String) {
        KKLoading.shared.hide()
        mainView.refreshControl.endRefreshing()
        Toast.share.show(message: message)
    }
    
    func displayUpdatedIsFollow() {
//        interactor.requestUserProfile(by: userId)
    }
    
    func displayProductEtalase(products: [ShopViewModel]) {
//        if mainView.selectedTabMenu == .showcase {
            if interactor.productCurrentPage <= 0 {
                mainView.products = products
//                showcaseController.productItems = products
            } else {
                mainView.products.append(contentsOf: products)
//                showcaseController.productItems.append(contentsOf: products)
            }
//        }
        
        
        mainView.refreshControl.endRefreshing()
//        showcaseController.reloadProducts()
        interactor.isLoading = false
    }
}

extension ProfileViewController: ProfileViewDelegate {
    func handleLoadMore() {
        switch mainView.selectedTabMenu {
        case .post:
            if interactor.postCurrentPage < interactor.postTotalPage && !interactor.isLoading {
                guard !interactor.isLoading else { return }
                interactor.isLoading = true
                interactor.postCurrentPage += 1
                interactor.requestUserProfilePost()
            }
        case .showcase:
            if interactor.productCurrentPage < interactor.productTotalPage && !interactor.isLoading {
                guard !interactor.isLoading else { return }
                interactor.isLoading = true
                interactor.productCurrentPage += 1
                interactor.requestProducts()
            }
        }
    }
    
    func handleTapSetting() {
        router.navigateToProfileMenu(isVerified: interactor.isVerified, accountType: mainView.user?.accountType ?? "USER")
    }
    
    func didClickShopButton(user: RemoteUserProfileData?) {
        router.navigateToMyProduct(isVerified: user?.isVerified ?? false)
    }
    
    func didRefreshPage() {
        defaultRequest()
    }

    func didTapProfilePicture(with image: UIImage?) {
        guard interactor.userId == getIdUser() else {
            router.presentPicturePreview(image: image, url: mainView.user?.photo)
            return
        }

        router.presentPictureOptions(image: image)
    }
    
    func didClickVisitor() {
        router.showInProgressDialog()
    }
    
    func didClickAddYours() {
        router.showInProgressDialog()
    }
    
    func didClickTotalLikes() {
        router.showInProgressDialog()
    }
    
    func didClickShare() {
        router.showInProgressDialog()
    }
    
    func didClickTotalFollowing() {
        router.navigateToFollowings(id: interactor.userId)
    }
    
    func didClickTotalFollower() {
        router.navigateToFollowers(id: interactor.userId)
    }
    
    func didClickDirectMessage() {
        let user = mainView.user
        router.navigateToDM(
            userId: interactor.userId,
            userName: user?.username,
            photo: user?.photo,
            isVerify: user?.isVerified ?? false
        )
    }
    
    func didClickYourOrders() {
        router.navigateToHistoryTransaction()
    }
}

extension ProfileViewController: ProfilePictureOptionsDelegate {
    func didTapPicture(image: UIImage?) {
        router.presentPicturePreview(image: image, url: mainView.user?.photo)
    }

    func didTapCamera() {
        router.presentCamera(onMediaSelected: handleSelectedMedia)
    }

    func didTapLibrary() {
        router.presentLibrary()
    }

    func didTapDonationBadge() {
        router.presentDonationRankAndBadge(accountId: interactor.userId)
    }

    private func handleSelectedMedia(with item: KKMediaItem) {
        router.presentPictureCropper(with: item)
    }
}

extension ProfileViewController: ProfilePictureCropDelegate {
    public func didCropped(media item: KKMediaItem) {
        interactor.requestUserProfileUploadPicture(with: item)
        KKLoading.shared.show()
    }
}

extension ProfileViewController: KKMediaPickerDelegate {
    public func didPermissionRejected() {
        KKMediaPicker.showAlertForAskPhotoPermisson(in: self)
    }

    public func didLoading(isLoading: Bool) {
        if isLoading {
            KKLoading.shared.show()
        } else {
            KKLoading.shared.hide()
        }
    }

    public func didSelectMedia(media item: KKMediaItem) {
        handleSelectedMedia(with: item)
    }
    
    public func displayError(message: String) {
        
    }

}

extension String {
    func trimFullName(limit: Int) -> String {
        let nsString = self as NSString
        if nsString.length >= limit {
            var trim = nsString.substring(with: NSRange(location: 0, length: nsString.length > limit ? limit : nsString.length))
            if trim.count == limit {
                trim += "..."
            }
            return trim
        }
        return self
    }
}

extension ProfileViewController: UIGestureRecognizerDelegate {
    
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer) {
//            //navigationController?.popViewController(animated: true)
//        }
//        return true
//    }

    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer) {
            if gestureRecognizer.state == .possible {
                return false
            }
        }
        return true
    }
}
