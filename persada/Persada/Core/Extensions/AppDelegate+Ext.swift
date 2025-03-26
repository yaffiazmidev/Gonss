//
//  AppDelegate+Ext.swift
//  KipasKipas
//
//  Created by DENAZMI on 04/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import OneSignal
import GoogleMaps
import GooglePlaces
import Sentry
import AVFoundation
import Branch
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import FirebaseAnalytics
import TUIPlayerShortVideo
import TUIPlayerCore
import FeedCleeps
import KipasKipasCall
import KipasKipasShared
import SDWebImage
import TXLiteAVSDK_Professional
import KipasKipasResetPasswordiOS
import RxSwift
import RxCocoa
import KipasKipasPaymentInAppPurchase
import KipasKipasDonationCart
import KipasKipasCamera

let notificationOpened = Notification.Name("com.kipaskipas.notificationOpened")
let notificationReceived = Notification.Name("com.kipaskipas.notificationReceived")

extension AppDelegate {
    func getUserBy(id: String) {
        
        struct Root: Codable {
            let code, message: String?
            let data: RootData?
        }
        
        struct RootData: Codable {
            let id: String?
            let name: String?
            let username: String?
            let photo: String?
            let isVerified: Bool?
        }
        
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "profile/\(id)",
            method: .get,
            headerParamaters: [
                "Authorization" : "Bearer \(getToken() ?? "")",
                "Content-Type":"application/json"
            ]
        )
        
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.message)
            case .success(let response):
                let nickName = response?.data?.name
                let profileURL = response?.data?.photo
                let isVerified = response?.data?.isVerified ?? false
                TXIMUserManger.shared.updateUserInfo(nickName: nickName, profileURL: profileURL, isVerified: isVerified)
                
                UserManager.shared.username = getUsername()
                UserManager.shared.userAvatarUrl = profileURL
                UserManager.shared.userVerify = isVerified
                
                let loggedInUser = loggedInUserStore.retrieve()
                let updateLoggedInUser = LoggedInUser(
                    role: loggedInUser?.role ?? "",
                    userName: loggedInUser?.userName ?? "",
                    userEmail: loggedInUser?.userEmail ?? "",
                    userMobile: loggedInUser?.userMobile ?? "",
                    accountId: loggedInUser?.accountId ?? "",
                    photoUrl: response?.data?.photo ?? ""
                )
                
                loggedInUserStore.insert(updateLoggedInUser)
                
                UserConnectionUseCase.shared.updateUserInfo(
                    nickname: response?.data?.username ?? "",
                    profileImageURL: response?.data?.photo ?? "")
                { result in
                    print("Update sendbird user profile")
                    switch result {
                    case .success(_):
                        let metaData = ["is_verified": response?.data?.isVerified == true ? "true" : "false"]
                        UserConnectionUseCase.shared.currentUser?.updateMetaData(metaData, completionHandler: { metaData, error in
                            print("Update user metadata")
                        })
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func handleDidFinishLaunchingWithOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        sendDeviceInfoToFirebaseAnalytics()
        setupSentry()
        setupTUIPlayer()
        setupRoot()
        setupGoogleMaps()
        
        setupNotification(launchOptions)
        setupNavBarAppearance()
//        setAudioMode()

        SendbirdSDKEnvUseCase.initialize(appId: APIConstants.sendbirdAppId)
        
        TXIMUserManger.shared.initSDK(appId: SDKAPPID)
        TXIMUserManger.shared.delegate = self
        loginIM()
    }
    
    private func setupNavBarAppearance() {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = .white
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
    
    private func setupGoogleMaps() {
        let gmapsKey = Bundle.main.infoDictionary!  ["GMAPS_KEY"] as! String
        GMSServices.provideAPIKey(gmapsKey)
        GMSPlacesClient.provideAPIKey(gmapsKey)
    }
    
    private func setupSentry() {
        //let users = ["bossgito", "pakgito", "erqyara", "yuya", "rifkibaru", "yasmine", "redpanda", "rony2"]
        let users = ["bossgito", "pakgito", "erqyara", "yuya", "rifkibaru", "yasmine", "redpanda", "rony2", "rony1", "rony3", "wuziyang", "shellinw"]
        SentrySDK.start { options in
            options.dsn = "https://0d84956d365a4faaa67f890f8f2c070a@o69159.ingest.sentry.io/5854348"
            options.debug = false // Enabled debug when first installing is always helpful
            options.attachScreenshot = true
            options.attachStacktrace = true
            options.attachViewHierarchy = true
            options.enableAppHangTracking = true
            options.enableCrashHandler = true
            options.enableUserInteractionTracing = true
            options.enabled = true
            options.environment = Bundle.main.infoDictionary!  ["SENTRY_ENVIRONMENT"] as? String ?? "production"
            //if users.contains(getUsername()) {
            options.enableCaptureFailedRequests = true
//                let httpStatusCodeRange = HttpStatusCodeRange(min: 400, max: 599)
//                options.failedRequestStatusCodes = [ httpStatusCodeRange ]
            //}
        }
        updateSentryUserData()
    }
    
    private func setupTUIPlayer() {
        let licence = TXLiveBase.getLicenceInfo()
        if licence.isEmpty {
            let config = TUIPlayerConfig()
            config.enableLog = true
            //        config.licenseUrl = "https://license.vod-control.com/license/v2/1316940742_1/v_cube.license"
            //        config.licenseKey = "7e83f0cac294d0b9f53a23c96b36c388"
            TUIPlayerCore.shareInstance().setPlayerConfig(config)
            //        TUIPlayerAuth.shareInstance().delegate = self
            
            TXLiveBase.setLicenceURL("https://license.vod-control.com/license/v2/1316940742_1/v_cube.license", key: "7e83f0cac294d0b9f53a23c96b36c388")
//            TXLiveBase.sharedInstance().delegate = self
        }


    }
    
    
    
    private func setupNotification(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (granted, error) in
            if granted {
                // Register after we get the permissions.
                UNUserNotificationCenter.current().delegate = self
            }
        })
        
        let notifWillShowInForegroundHandler: OSNotificationWillShowInForegroundBlock = { notification, completion in
            print("Received Notification: ", notification.notificationId ?? "no id")
            print("launchURL: ", notification.launchURL ?? "no launch url")
            print("content_available = \(notification.contentAvailable)")
            let notificationId = notification.notificationId
            notificationId == "example_silent_notif" ? completion(nil) : completion(notification)
            NotificationCenter.default.post(name: Notification.Name("com.kipaskipas.updateNotificationCounterBadge"), object: nil)
        }
        
        let notificationOpenedBlock: OSNotificationOpenedBlock = { result in
            let payload: OSNotification = result.notification
            var fullMessage = payload.body
            
            if let additionalData = payload.additionalData?["actionSelected"] {
                fullMessage = fullMessage! + "\nPressed ButtonID: \(additionalData)"
            }
            
            NotificationCenter.default.post(name: notificationOpened, object: payload)
        }
        
        //START OneSignal initialization code
        OneSignal.initWithLaunchOptions(launchOptions)
        let oneSignalID = Bundle.main.infoDictionary!  ["ONE_SIGNAL_ID"] as! String
        OneSignalManager.shared.appId = oneSignalID
        OneSignalManager.shared.apiKey = Bundle.main.infoDictionary!  ["ONE_SIGNAL_REST_API_KEY"] as! String
        OneSignal.setAppId(oneSignalID)
        OneSignal.setNotificationWillShowInForegroundHandler(notifWillShowInForegroundHandler)
        OneSignal.setNotificationOpenedHandler(notificationOpenedBlock)
        
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
    }
    
    private func setupRoot() {
        clearNotifsNav()
        let window = UIWindow(frame: UIScreen.main.bounds)
        //window.overrideUserInterfaceStyle = .dark
        let vc = MainTabController()
        vc.notifsNavigate?.configureNotif()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window
    }
	
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        Branch.getInstance().continue(userActivity)
        continueVoIP(userActivity: userActivity)
        
        universalLinkManager.handleNavigationUniversalLink(object: userActivity)
        return true
    }
	
    func applicationDidBecomeActive(_ application: UIApplication) {
        checkGallery()
        playerController()?.resumeIfNeeded()
        NotificationCenter.default.post(name: .updateDonationCampaign, object: nil)
        URLSchemes.instance.didBecomeActive()
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.showBadgeCount()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        showBadgeCount()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        KKCache.common.save(integer: 0, key: .unreadNotificationCount(getIdUser()))
        NotificationCenter.default.post(name: .notifyWillEnterForeground, object: nil)
        NotificationCenter.default.post(name: .notifyWillEnterForegroundFeed, object: nil)
//        setAudioMode()
        refreshToken {  }
        
        if TUICallStateViewModel.shared.state == .notOnCall {
            do {
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            }
        } else {
            do {
                try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoChat)
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
//        setAudioOff()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.showBadgeCount()
        }
    }
    
    private func playerController() -> IHotNewsViewController? {
        guard let topViewController = window?.topViewController as? NewHomeController,
              let playerController = topViewController.selectedViewController as? IHotNewsViewController else {
            return nil
        }
        return playerController
    }
    
    private func checkGallery(){
        if KKQRHelper.stateAskPhoto{
            if let controller = self.topMostController(){
                if UserDefaults.standard.bool(forKey: KKQRHelper.userDefaultKey) {
                    KKQRHelper.stateAskPhoto = false
                    KKQRHelper.fetchPhotosQR(controller) { str in }
                }
            }
        }
    }
    
    private func topMostController() -> UIViewController? {
        let topController : UIViewController?
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        topController = appDelegate.window?.rootViewController
        
        if let navigationController = topController as? UINavigationController {
            return navigationController.viewControllers.first?.presentedViewController
        }
        
        return topController
    }
    
    private func setAudioOff() {
        do {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(false)
        } catch (let err){
            print("setAudioMode error:" + err.localizedDescription)
        }
    }
    
    private func setAudioMode() {
        do {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch (let err){
            print("setAudioMode error:" + err.localizedDescription)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let payload = notification.request.content.userInfo
        let customObject = payload["custom"] as? [String: AnyObject]
        
        if let object = customObject?["a"] as? [String: Any],
            let from = object["notif_from"] as? String,
            from == "chat" {
            (window?.topViewController as? NewHomeController)?.loadUnreadMessageCount()
            completionHandler([])
        } else {
            completionHandler([.badge, .alert, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let payload = response.notification.request.content.userInfo
        let customObject = payload["custom"] as? [String: AnyObject]
        
        guard let object = customObject?["a"] as? [String: Any] else {
            return
        }
        
        pushNotifManager.handleNotification(object: object)
        
        completionHandler()
    }
}

extension AppDelegate: PushNotificationManagerDelegate, UniversalLinkDelegate {
    func navigate(to destination: PushNotificationDestination) {
        switch destination {
        case let .profile(_, userId):
            guard let userId = userId else { return }
            
            let vc = ProfileRouter.create(userId: userId)
            vc.bindNavigationBar(
                "",
                icon: "ic_chevron_left_outline_black",
                customSize: .init(width: 20, height: 14),
                contentHorizontalAlignment: .fill,
                contentVerticalAlignment: .fill
            )
            vc.hidesBottomBarWhenPushed = true
            
            window?.topViewController?.dismiss(animated: true) { [weak self] in
                self?.window?.topNavigationController?.pushViewController(vc, animated: true)
            }
        case let .singleFeed(feedId):
            guard let feedId = feedId else { return }

            let vc = HotNewsFactory.createSingleFeed(selectedFeedId: feedId)
            vc.bindNavigationBar("")
            vc.hidesBottomBarWhenPushed = true
            
            window?.topViewController?.dismiss(animated: true) { [weak self] in
                self?.window?.topNavigationController?.pushViewController(vc, animated: true)
            }
        case .donationTransaction(let orderId):
            let destination = DetailTransactionDonationFactory.createWaitingController(orderId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.pushOnceAndPopLast(destination, animated: true)
            }
            
        case .donationDetail(let donationId):
            let destination = DonationDetailViewController(donationId: donationId, feedId: "")
            destination.hidesBottomBarWhenPushed = true
            
            window?.topViewController?.dismiss(animated: true) { [weak self] in
                self?.pushOnceAndPopLast(destination)
            }
        
        case .live:
            showLiveStreamingList?(nil)
        }
    }
    
    func navigate(to page: DeeplinkPage) {
        switch page {
        case let .donation(id):
            let destination = DonationDetailViewController(donationId: id, feedId: "")
            destination.hidesBottomBarWhenPushed = true
            pushOnce(destination)
            
        case let .feed(feed):
            
            guard let feedId = feed.id else { return }

            let vc = HotNewsFactory.createSingleFeed(selectedFeedId: feedId)
            vc.bindNavigationBar("")
            vc.hidesBottomBarWhenPushed = true
            
            window?.topViewController?.dismiss(animated: true) { [weak self] in
                self?.window?.topNavigationController?.pushViewController(vc, animated: true)
            }
            
        case let .registerVerification(code, token):
            registerVerifyEmailAdapter.verifyEmail(
                with: .init(
                    code: code,
                    token: token,
                    deviceId: UIDevice.current.identifierForVendor?.uuidString ?? ""
                ),
                onSuccessVerifyEmail: { [weak self] isSuccess in
                    if isSuccess {
                        self?.window?.topViewController?.showToast(
                            with: "Verifikasi email berhasil",
                            duration: 3,
                            verticalSpace: 50
                        )
                    }
                },
                onFailedVerifyEmail: { [weak self] _ in
                    self?.showAlertEmailVerificationFailed()
                }
            )
        case let .resetPasswordVerification(code, token):
            guard let top = window?.topViewController else { return }
            
            if let controller = top as? ResetPasswordVerifyOTPViewController {
                controller.setOTP(with: code, token: token)
            } else {
                showAlertEmailVerificationFailed()
            }
        }
    }
    
    func showToast(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.window?.topViewController?.showToast(with: message, verticalSpace: 50)
        }
    }
    
    private func showAlertEmailVerificationFailed() {
        let button = UIAlertAction(
            title: "Mengerti",
            style: .default
        )
        button.titleTextColor = .night
        window?.topViewController?.showAlertController(
            title: "Tidak dapat memverifikasi alamat email",
            titleFont: .roboto(.bold, size: 20),
            message: "\nTerjadi kesalahan. Pastikan untuk menggunakan perangkat yang sama dengan yang kamu gunakan untuk mengirim email verifikasi.\n",
            messageFont: .roboto(.regular, size: 14),
            backgroundColor: .white,
            actions: [button]
        )
    }
}

extension AppDelegate {
    private func sendDeviceInfoToFirebaseAnalytics() {
        var params = getDeviceInfo()
        let username = getUsername().isEmpty ? "EMPTY" : getUsername()
        params["username"] = username
        Analytics.logEvent("device_info_\(username)", parameters: params)
    }

    func getDeviceInfo() -> [String: String] {
        var params: [String: String] = [:]
        let device = UIDevice.current

        params["model_name"] = UIDevice.modelName
        params["system_version"] = device.systemVersion

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            params["app_version"] = version
        }

        if let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            params["build_number"] = buildNumber
        }


        if let identifierForVendor = UIDevice.current.identifierForVendor {
            let uuidString = identifierForVendor.uuidString
            params["device_UUID"] = uuidString
        }

        return params
    }
    
    func clearCacheTUI() {
        
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let diskCacheStorageBaseUrl = myDocuments.appendingPathComponent("tuiplayervideocache")
        guard let filePaths = try? fileManager.contentsOfDirectory(at: diskCacheStorageBaseUrl, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }

}

extension AppDelegate {
//    func setupSDWebImage() {
//        let cacheConfig = SDImageCacheConfig()
//        cacheConfig.maxDiskAge = 30
////        cacheConfig.diskCacheExpireType = .accessDate
//        SDWebImageManager.shared.imageCache.config = cacheConfig
//    }
    
    func clearSDWebImageExpiredCache() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
    }
}

extension AppDelegate: TXIMUserMangerDelegate {
    func onIMUserKickedOffline() {
        logout()
    }
    
    func onIMUserSigExpired() {
        loginIM()
    }
    
    private func logout() {
        KeychainUserStore().remove()
        KKCache.common.remove(key: .trendingCache)
        logoutResponse()
    }

    private func logoutResponse() {
        KKFeedCache.instance.clear()
        DataCache.instance.cleanAll()
        InAppPurchasePendingManager.instance.destroy()
        KKFeedLike.instance.reset()
        callAuthenticator.logout { result in
            switch result {
            case .failure(let error):
                print("Call Feature: Failure Logout", error.localizedDescription)
            case .success(_):
                print("Call Feature: Success Logout")
            }
        }
        
        DonationCartManager.instance.logout()
        // Removing External User Id with Callback Available in SDK Version 2.13.1+
        OneSignal.removeExternalUserId({ results in
            // The results will contain push and email success statuses
            print("External user id update complete with results: ", results!.description)
            // Push can be expected in almost every situation with a success status, but
            // as a pre-caution its good to verify it exists
            if let pushResults = results!["push"] {
                print("Remove external user id push status: ", pushResults)
            }
            // Verify the email is set or check that the results have an email success status
            if let emailResults = results!["email"] {
                print("Remove external user id email status: ", emailResults)
            }
        })
            
        DispatchQueue.main.async {
            StorySimpleCache.instance.saveStories(stories: [])
            removeToken()
            self.clearNotifsNav()
            let mainTabController = MainTabController()
            mainTabController.notifsNavigate?.configureNotif()
            self.window?.switchRootViewController(mainTabController, animated: false)
            NotificationCenter.default.post(name: .showOnboardingView, object: nil, userInfo: [:])
        }
    }
}
