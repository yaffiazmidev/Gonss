//
//  MainTabController.swift
//  Persada
//
//  Created by Muhammad Noor on 02/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FeedCleeps
import KipasKipasNetworking
import SendbirdChatSDK
import KipasKipasShared
import KipasKipasNotification
import KipasKipasNotificationiOS

protocol UploadDelegate {
    func onUploadCallBack(param : PostFeedParam)
}

class MainTabController: UITabBarController {
    
    // MARK: - Public Method
    
    var uploadDelegate : UploadDelegate!
    var postController: PostController?
    private let imagePickerTag = 999
    private var isDarkTheme = false
    
    let popup = AuthPopUpViewController(mainView: AuthPopUpView())
    let usecase = Injection.init().provideProfileUseCase()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    let disposeBag = DisposeBag()
    private let checker = FeedbackCheckerFactory.create()
    private var itemsEnabled: [Bool] = []
    
    lazy var homeController: NewHomeController = {
        let controller = NewHomeController()
        controller.delegate = self
        return controller
    }()
    
    lazy var notifsNavigate: PushNotifNavigate? = {
        let navigates = PushNotifNavigate()
        return navigates
    }()
    
      
    lazy var pinchScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .black.withAlphaComponent(0.6)
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var pinchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = false
        return imageView
    }()
    
    private var notifUnreadCount: Int = 0 {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabBar.addItemBadge(atIndex: 3, counter: self.notifUnreadCount)
            }
        }
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        ProxyServer.shared.start()
        self.delegate = self
        
        //		let channelController = AUTH.isLogin() ? NewChannelController(mainView: NewChannelView(), dataSource: NewChannelModel.DataSource()) : GuestChannelController(mainView: GuestChannelView(), dataSource: GuestChannelController.DataSource())
        
//        let shopController = ShopUIFactory.create(isPublic: !AUTH.isLogin())
        let shopController = ShopComingSoonController()
        uploadDelegate = homeController
        let notificationController = notificationViewController!(getIdUser())
//        let notificationController = NotificationController.init(presenter: NotificationPresenter())
        
        let shopActive = UIImage(named: .get(.iconShopActiveLight))!
        let shopIdle = UIImage(named: .get(.iconShopIdleDark))!
        let notifActive = UIImage(named: .get(.iconNotifActiveLight))!
        let notifIdle = UIImage(named: .get(.iconNotifIdleDark))!

//        var tabBarHeight = self.tabBar.frame.size.height;
//        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        //let videoMarginHeightFloat = tabBarHeight + statusBarHeight
        var videoMarginHeightFloat = UIDevice.tabHeight // 83.0 // iphone 13

        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets
        if safeAreaInsets?.top ?? 0 > 24 {
            videoMarginHeightFloat += Int(safeAreaInsets?.bottom ?? 0)
        }
        
        let videoMarginHeight =  String(describing: videoMarginHeightFloat)
        
//        print("*** debugTui tabBarHeight:", tabBarHeight, "statusBarHeight:", statusBarHeight, "videoMarginHeight:", videoMarginHeight, "videoMarginHeightFloat:", videoMarginHeightFloat)
        
        viewControllers = [
            generateHomeController(),
            generateViewController(source: shopController, selectedImage: shopActive ,unselectedImage: shopIdle, label: "Shop"),
            generateImagePickerTabBar(),
            generateViewController(source: notificationController, selectedImage: notifActive, unselectedImage: notifIdle, label: "Notifikasi"),
            generateProfileController(),
        ]
        
        viewControllers?.forEach({ _ in
            itemsEnabled.append(true)
        })
        
        guard let items = tabBar.items else { return }
        
        addOrRemoveRedDot()
        
        selectedIndex = 1
        selectedIndex = 0
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        createRedDotObserver()
        checkQRGallery()
        setTabBarDark()
        let code = DataCache.instance.readString(forKey: "REFFCODE")
        print("MainTabControlller - Referral Code: \(code)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(hotnewsCellPinchImage(notification:)), name: .init("hotnewsCellPinchImage"), object: nil)
        
        loadNotificationUnreads()
    }
    
    //return true if removed success.
    @discardableResult
    public func removeItemBadge(atIndex index: Int) -> Bool {
        for subView in self.view.subviews {
            if subView.tag == (tabBarItemTag + index) {
                subView.removeFromSuperview()
                return true
            }
        }
        return false
    }
    
    private func checkFeedback() {
        checker.check { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                if !item.hasFeedback {
                    self.tabBar.addItemBadge(atIndex: 4)
                } else {
                    self.tabBar.removeItemBadge(atIndex: 4)
                }
            case .failure:
                self.tabBar.removeItemBadge(atIndex: 4)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleCheckSaveQRCode()
    }
    
    func handleCheckSaveQRCode() {
        if KKQRHelper.stateAskPhoto{
            KKQRHelper.stateAskPhoto = false
            KKQRHelper.fetchPhotosQR(self) { str in }
        }
    }
    
    func showPopUp() {
        showLogin?()
    }
    
    func addOrRemoveRedDot(){
        if getEmail().isEmpty {
            tabBar.addItemBadge(atIndex: 4)
        } else {
            tabBar.removeItemBadge(atIndex: 4)
        }
    }
    
    func createRedDotObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateRedDot(notification:)), name: .notificationUpdateEmail, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationRedDot(notification:)), name: .notifyUpdateCounterSocial, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationRedDot(notification:)), name: .notifyUpdateCounterTransaction, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNotificationBadgeCounter),
            name: Notification.Name("com.kipaskipas.updateNotificationCounterBadge"),
            object: nil
        )
    }
    
    @objc func updateNotificationBadgeCounter() {
        loadNotificationUnreads()
    }
    
    @objc
    func updateRedDot(notification : NSNotification){
        addOrRemoveRedDot()
        checkFeedback()
    }
    
    @objc
    func updateNotificationRedDot(notification: NSNotification) {
        guard let data = (notification.object as? [String: Any])?.first?.value as? Tampung else {
            return
        }
        
        if data.size ?? 0 != 0 {
//            tabBar.addItemBadge(atIndex: 3)
        } else {
//            tabBar.removeItemBadge(atIndex: 3)
        }
    }
    
    private func checkQRGallery(){
        KKQRHelper.fetchPhotosQR(self) { str in
            print(str)
        }
    }
    
    deinit {
        notifsNavigate?.cleanNotif()
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainTabController: ViewControllerFactory, UITabBarControllerDelegate {
    func generateViewController(source: UIViewController, selectedImage: UIImage, unselectedImage: UIImage) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: source)
        navigationController.tabBarItem.image = unselectedImage.withRenderingMode(.alwaysTemplate)
        navigationController.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
        return navigationController
    }
    
    private func generateViewController(source: UIViewController, selectedImage: UIImage, unselectedImage: UIImage, label: String) -> UIViewController {
        let controller = generateViewController(source: source, selectedImage: selectedImage, unselectedImage: unselectedImage)
        controller.tabBarItem.title = label
        return controller
    }
    
    private func generateHomeController() -> UIViewController {
        let idle = UIImage(named: String.get(.iconHomeIdleLight))!
        let active = UIImage(named: .get(.iconHomeActiveDark))!
        let homeFeedVC = generateViewController(source: homeController, selectedImage: active ,unselectedImage: idle, label: "Home")
        notifsNavigate?.controller = homeFeedVC
        return homeFeedVC
    }
    
    private func generateImagePickerTabBar() -> UIViewController {
        let controller = UIViewController()
        controller.tabBarItem.tag = imagePickerTag
        controller.tabBarItem.image = UIImage(named: String.get(.iconPostIdleLight))?.withRenderingMode(.alwaysTemplate)
        controller.tabBarItem.selectedImage = UIImage(named: String.get(.iconPostIdleLight))
        controller.tabBarItem.title = ""
        return controller
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "shouldResumePlayer"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "shouldPausePlayer"), object: nil)
    }
    
    private func generateProfileController() -> UIViewController {
        let idle = UIImage(named: .get(.iconProfileIdleDark))!
        let active = UIImage(named: .get(.iconProfileActiveLight))!
        
//        let userProfileSource = NewUserProfileViewController(mainView: NewUserProfileView(), dataSource: NewUserProfileModel.DataSource())
//        if getRole() == "ROLE_SELEB" {
//            userProfileSource.setProfile(id: getIdUser(), type: "seleb")
//        } else {
//            userProfileSource.setProfile(id: getIdUser(), type: "social")
//        }
        let vc = ProfileRouter.create(userId: getIdUser())
        let userProfileVC = generateViewController(source: vc, selectedImage: active, unselectedImage: idle, label: "Profile")
        return userProfileVC
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == imagePickerTag {
            if !AUTH.isLogin(){
                showPopUp()
            } else {
                showCamerasViewController?({ [weak self] (item) in
                    guard let self = self else { return }
                    
                    switch item.postType  {
                    case .feed:
                        self.showPostController([item])
                    case .story:
                        selectedIndex = 0 // back to home
                        updateTheme()
                        homeController.pagingViewController.select(index: 1) // navigate to following
                        if let vc = self.homeController.followingViewController as? IHotStoryViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                vc.expandStoryListView()
                            }
                        }
                        createStoryPost?([item])
                    }
                })
            }
            
            return false
        } else if viewController.isKind(of: ProfileViewController.self) {
//            let vc = viewController as! ProfileViewController
//            vc.userId = getIdUser()
//            vc.defaultRequest()
            homeController.hotNewsViewController.pauseIfNeeded()
        } else if (viewController as! UINavigationController).viewControllers.first?.isKind(of: ProfileViewController.self) ?? false {
            
            if !AUTH.isLogin(){
                showPopUp()
                return false
            }
            
            homeController.hotNewsViewController.pauseIfNeeded()
            
            guard let vc = (viewController as? UINavigationController)?.viewControllers.first as? ProfileViewController else { return false }
            vc.interactor.userId = getIdUser()
            
        } else if (viewController as! UINavigationController).viewControllers.first?.isKind(of: KipasKipasNotificationiOS.NotificationController.self) ?? false {
            if !AUTH.isLogin(){
                showPopUp()
                return false
            }
        }
        
        guard let viewControllers = viewControllers else { return false }

        // this code greying item when disable
//        if let controller = (viewController as? UINavigationController)?.viewControllers.first,
//           let index = tabBarController.viewControllers?.firstIndex(of: viewController),
//           controller.isKind(of: NewHomeController.self) {
//            preventRepeatedSelect(for: index)
//        }
        
        if let controller = (viewController as? UINavigationController)?.viewControllers.first,
           let index = tabBarController.viewControllers?.firstIndex(of: viewController),
           controller.isKind(of: NewHomeController.self) {
            if preventRepeatedTap(for: index) { // if true, the item is on disable state
                return false
            }
        }
        
        if viewController == viewControllers[selectedIndex] {
            if let nav = viewController as? UINavigationController {
                guard let topController = nav.viewControllers.last else { return true }
                if !topController.isScrolledToTop {
                    topController.scrollToTopList()
                    return false
                } else {
                    nav.popViewController(animated: true)
                    topController.scrollToTopList()
                }
                return true
            }
        }
        
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // notifsNavigate.controller?.viewWillDisappear(true)
        if let nav = viewController as? UINavigationController {
            print("navnavfi1 = \(type(of: nav.viewControllers.last))")
        } else {
            print("navnavfi = \(type(of: viewController))")
        }
        notifsNavigate?.controller = viewController
        updateTheme()
        if selectedIndex != 3 {
            loadNotificationUnreads()
        } else {
            tabBar.addItemBadge(atIndex: 3, counter: notifUnreadCount)
        }
    }
    
    private func showPostController(_ medias: [KKMediaItem]) {
        var dataSource = PostModel.DataSource()
        dataSource.itemMedias = medias
        postController = PostController(mainView: PostView(isCreateFeed: true), dataSource: dataSource)
        postController?.onPostClickCallback = { postParam in
            self.uploadDelegate.onUploadCallBack(param: postParam)
            self.postController?.dismiss(animated: true)
        }
        guard let controller = postController else { return }
        let navigate = UINavigationController(rootViewController: controller)
        navigate.modalPresentationStyle = .fullScreen
        self.present(navigate, animated: true, completion: nil)
    }
    
    
}

protocol ViewControllerFactory {
    func generateViewController(source: UIViewController, selectedImage: UIImage ,unselectedImage: UIImage) -> UIViewController
}

fileprivate let tabBarItemTag: Int = 10090
extension UITabBar {
    public func addItemBadge(atIndex index: Int, counter: Int = 0) {
        guard let itemCount = self.items?.count, itemCount > 0 else {
            return
        }
        
        guard index < itemCount else {
            return
        }
        
        removeItemBadge(atIndex: index)
        
        if index == 3 {
            addItemBadgeCounter(atIndex: index, counter: counter)
            return
        }
        
        let badgeView = UIView()
        badgeView.tag = tabBarItemTag + Int(index)
        badgeView.clipsToBounds = true
        badgeView.layer.cornerRadius = 2.5
        badgeView.backgroundColor = UIColor.gradientStoryOne

        let tabFrame = self.frame
        let percentX = (CGFloat(index) + 0.56) / CGFloat(itemCount)
        let x = (percentX * tabFrame.size.width).rounded(.up)
        let y = (CGFloat(0.1) * tabFrame.size.height).rounded(.up)
        badgeView.frame = CGRect(x: x, y: y, width: 5, height: 5)
        
        addSubview(badgeView)
    }
    
    private func addItemBadgeCounter(atIndex index: Int, counter: Int) {
        guard let itemCount = self.items?.count, itemCount > 0 else { return }
        guard counter > 0 else { return }
        
        let isDark = barTintColor == .black

        let badgeView = UIView()
        badgeView.tag = tabBarItemTag + Int(index)
        badgeView.clipsToBounds = true
        badgeView.layer.cornerRadius = isDark ? 6 : 8
        badgeView.backgroundColor = UIColor.gradientStoryOne
        
        let counterLabel = UILabel()
        counterLabel.textColor = .white
        counterLabel.backgroundColor = .clear
        counterLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        counterLabel.text = counter < 100 ? "\(counter)" : "99+"
        counterLabel.textAlignment = .center
        counterLabel.frame = .init(
            x: 0, y: 0,
            width: counter < 10 ? (isDark ? 12 : 16) : counter < 100 ? (isDark ? 22 : 26) : (isDark ? 27 : 31),
            height: isDark ? 12 : 16
        )
        
        badgeView.addSubview(counterLabel)
        badgeView.layer.borderWidth = 2
        badgeView.layer.borderColor = isDark ? UIColor.gradientStoryOne.cgColor : UIColor.white.cgColor

        let tabFrame = self.frame
        let percentX = (CGFloat(index) + 0.56) / CGFloat(itemCount)
        let x = (percentX * tabFrame.size.width).rounded(.up)
        let y = (CGFloat(0.1) * tabFrame.size.height).rounded(.up)
        badgeView.frame = CGRect(
            x: counter < 10 ? (x - 5) : (x - 10),
            y: isDark ? (y / 2 ) + 2 : (y / 2 ),
            width: counter < 10 ? (isDark ? 12 : 16) : counter < 100 ? (isDark ? 22 : 26) : (isDark ? 27 : 31),
            height: isDark ? 12 : 16
        )
        addSubview(badgeView)
    }
    
    //return true if removed success.
    @discardableResult
    public func removeItemBadge(atIndex index: Int) -> Bool {
        for subView in self.subviews {
            if subView.tag == (tabBarItemTag + index) {
                subView.removeFromSuperview()
                return true
            }
        }
        return false
    }
}

private extension UIViewController {
    func scrollToTopVC() {
        func scrollToTopVC(view: UIView?) {
            guard let view = view else { return }
            
            switch view {
            case let scrollView as UIScrollView:
                if scrollView.scrollsToTop == true {
                    scrollView.setContentOffset(CGPoint(x: 0.0, y: -scrollView.contentInset.top), animated: true)
                    return
                }
            default:
                break
            }
            
            for subView in view.subviews {
                scrollToTopVC(view: subView)
            }
        }
        
        scrollToTopVC(view: view)
    }
    
    func scrollToTopList(){
        switch self {
        case is NewHomeController:
            handleHomeRefresh()
        case is ShopViewController:
            let controller = (self as! ShopViewController)
            if !(controller.getProducts() == 0) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    controller.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                })
            }
            break
        case is NewUserProfileViewController:
            let controller = (self as! NewUserProfileViewController)
            if !(controller.presenter.feedsDataSource.value.isEmpty) {
                (self as! NewUserProfileViewController).mainView.collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: true)
            }
        case is NotificationController:
            switch (self as! NotificationController).controllerIndex  {
            case 0:
                let controller = (self as! NotificationController).viewControllerList[0]
                if !(controller as! NotificationSocialController).presenter.notificationResult.value.isEmpty {
                    (controller as! NotificationSocialController).mainView.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableView.ScrollPosition(rawValue: 0)!, animated: true)
                }
                
                
            case 1:
                let controller = (self as! NotificationController).viewControllerList[1]
                if !(controller as! NotificationTransactionController).presenter.notificationResult.value.isEmpty {
                    (controller as! NotificationTransactionController).mainView.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableView.ScrollPosition(rawValue: 0)!, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        (controller as! NotificationTransactionController).mainView.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    })
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    // Changed this
    
    var isScrolledToTop: Bool {
        if self is UITableViewController {
            return (self as! UITableViewController).tableView.contentOffset.y == 0
        }
        for subView in view.subviews {
            if let scrollView = subView as? UIScrollView {
                return (scrollView.contentOffset.y == 0)
            }
        }
        return true
    }
    
    func handleHomeRefresh() {
        guard let homeController = (self as? NewHomeController) else { return }
        let index = homeController.controllerIndex
        
        if let controller = homeController.viewControllerList[index] as? IHotNewsViewController {
            controller.pullToRefresh()
            return
        }
        
        if let tab = homeController.viewControllerList[index] as? FeedTabController, let controller = tab.viewControllerList[tab.controllerIndex] as? IHotNewsViewController {
            controller.pullToRefresh()
            return
        }
    }
}

// MARK: - Helper
private extension MainTabController {
    func setTabBarDark() {
        guard !isDarkTheme else { return }
        isDarkTheme = true
        self.tabBar.barTintColor = .black
        self.tabBar.backgroundColor = .black
        
        let idle: [AssetEnum] = [.iconHomeIdleDark, .iconShopIdleDark, .iconPostIdleDark, .iconNotifIdleDark, .iconProfileIdleDark]
        let active: [AssetEnum] = [.iconHomeActiveDark, .iconShopIdleDark, .iconPostIdleDark, .iconNotifIdleDark, .iconProfileIdleDark] // next ini harus di update untuk penyesuaian state active dark
        
        for i in 0..<(viewControllers?.count ?? 0){
            if let controller = viewControllers?[i] {
                controller.tabBarItem.image = UIImage(named: .get(idle[i]))!.withRenderingMode(.alwaysOriginal)
                controller.tabBarItem.selectedImage = UIImage(named: .get(active[i]))!.withRenderingMode(.alwaysOriginal)
//                controller.tabBarItem.imageInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
            }
        }
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
//        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 6)
//        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 6)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.placeholder]
        self.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    func setTabBarLight() {
        guard isDarkTheme else { return }
        isDarkTheme = false
        self.tabBar.barTintColor = .white
        self.tabBar.backgroundColor = .white
        
        let idle: [AssetEnum] = [.iconHomeIdleLight, .iconShopIdleLight, .iconPostIdleLight, .iconNotifIdleLight, .iconProfileIdleLight]
        let active: [AssetEnum] = [.iconHomeActiveLight, .iconShopActiveLight, .iconPostIdleLight, .iconNotifActiveLight, .iconProfileActiveLight]
        
        for i in 0..<(viewControllers?.count ?? 0){
            if let controller = viewControllers?[i] {
                controller.tabBarItem.image = UIImage(named: .get(idle[i]))!.withRenderingMode(.alwaysOriginal)
                controller.tabBarItem.selectedImage = UIImage(named: .get(active[i]))!.withRenderingMode(.alwaysOriginal)
//                controller.tabBarItem.imageInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
            }
        }
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .systemGray
//        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 6)
//        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 6)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primary]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    func preventRepeatedTap(for index: Int, inNext seconds: Double = 1) -> Bool {
        if itemsEnabled[index] {
            itemsEnabled[index] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.itemsEnabled[index] = true
            }
        } else {
            return true
        }
        
        return false
    }
    
    func updateTheme() {
        if selectedIndex == 0 {
            if homeController.theme == .dark {
                setTabBarDark()
            } else {
                setTabBarLight()
            }
            return
        }
        
        setTabBarLight()
    }
}

// MARK: - Handler Image Pinch
private extension MainTabController {
    @objc
    func hotnewsCellPinchImage(notification : NSNotification) {
        if let image = notification.object as? UIImage {
            showPinchView(with: image)
        }
    }
    
    func showPinchView(with image: UIImage) {
        pinchScrollView.frame = view.bounds
        pinchImageView.frame = pinchScrollView.bounds
        view.addSubview(pinchScrollView)
        pinchScrollView.addSubview(pinchImageView)
        pinchImageView.image = image
    }
    
    func hidePinchView() {
        pinchImageView.removeFromSuperview()
        pinchScrollView.removeFromSuperview()
    }
}

extension MainTabController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pinchImageView
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.zoomScale <= scrollView.minimumZoomScale {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        hidePinchView()
    }
}

// MARK: - Home Delegate
extension MainTabController: NewHomeControllerDelegate {
    func didChangedTheme(with theme: NewHomeTheme) {
        updateTheme()
    }
}

// MARK: - Helper
extension UITabBarController {
    func preventRepeatedSelect(for index: Int, inNext seconds: Double = 1) {
        guard let items = tabBar.items,
              !items.isEmpty,
              items.count > index
        else { return }
        
        items[index].isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            items[index].isEnabled = true
        }
    }
}

extension MainTabController {
    
    func loadNotificationUnreads() {
        guard AUTH.isLogin() else { return }
        tabBar.addItemBadge(atIndex: 3, counter: notifUnreadCount)
        NotificationUnreadsService.shared.load { [weak self] item in
            guard let self = self else { return }
            guard item.totalUnread != self.notifUnreadCount else { return }
            self.notifUnreadCount = item.totalUnread
        }
    }
}

extension UITabBar {
    func frameForTab(at index: Int) -> CGRect {
        guard let items = items, items.count > index else {
            return .zero
        }
        
        let numberOfItems = CGFloat(items.count)
        let tabBarWidth = frame.width
        let itemWidth = tabBarWidth / numberOfItems
        
        let xPosition = itemWidth * CGFloat(index)
        let yPosition = frame.origin.y
        
        return CGRect(x: xPosition, y: yPosition, width: itemWidth, height: frame.height)
    }
}
