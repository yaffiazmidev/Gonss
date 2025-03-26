import UIKit
import Combine
import KipasKipasLogin
import KipasKipasLoginiOS
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasPaymentInAppPurchase
import FirebaseAnalytics
import KipasKipasRegisteriOS
import KipasKipasDonationCart

// TODO: Need to follow up
import FeedCleeps

var showLogin: (() -> Void)?

extension AppDelegate {
    func configureLoginFeature() {
        KipasKipas.showLogin = showLoginOptions
    }
    
    private func showLoginError(error: AnyError) {
        guard let errorCode = Int(error.code) else { return }
        
        switch errorCode {
        case NSURLErrorTimedOut, NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            window?.topViewController?.showToast(with: "No internet connection")
        default: break
        }
    }
    
    func saveLogin(_ response: LoginResponse) {
        updateLoginData(data: response)
        saveUserLoggedIn(from: response)
        DataCache.instance.write(string: "", forKey: "REFFCODE")
        UserDefaults.standard.setValue(response.accountID, forKey: "USER_LOGIN_ID")
        DataCache.instance.write(string: response.userName ?? "", forKey: "KEY_AUTH_USERNAME")
        updateSentryUserData()
        loginIM(with: response.accountID ?? "")
        connectOneSignal(with: response.accountID ?? "")
        InAppPurchasePendingManager.instance.initialize(baseUrl: baseURL, userId: response.accountID ?? "", client: authenticatedHTTPClient)
        DonationCartManager.instance.login(user: response.accountID ?? "")
        KKFeedLike.instance.reset()
        verifyIdentityStored.remove()
    }
    
    private func saveUserLoggedIn(from response: LoginResponse) {
        let user = LoggedInUser(
            role: response.role ?? "",
            userName: response.userName ?? "",
            userEmail: response.userEmail ?? "",
            userMobile: response.userMobile ?? "",
            accountId: response.accountID ?? "",
            photoUrl: ""
        )
        
        loggedInUserStore.insert(user)
    }
    
   public func clearNotifsNav(){
        if let tab = self.window?.rootViewController, tab is MainTabController {
            let mainTab = tab as? MainTabController
            mainTab?.notifsNavigate?.cleanNotif()
            mainTab?.notifsNavigate = nil
        }
    }
    
    private func showNextViewController() {
        clearNotifsNav()
        let mainTabController = MainTabController()
        mainTabController.notifsNavigate?.configureNotif()
        self.window?.switchRootWithPushTo(viewController: mainTabController)
        
        self.sendAnalytics()
    }
    
    private func sendAnalytics() {
        var params = getDeviceInfo()
        let username = getUsername().isEmpty ? "EMPTY" : getUsername()
        params["username"] = username
        Analytics.logEvent("device_info_\(username)", parameters: params)
    }
}

// MARK: Loader Publisher
private extension AppDelegate {
    func makeLoginLoader(_ param: LoginRequestParam) -> API<LoginResponse, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/login")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<LoginResponse>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(
                    code: mappedError.code,
                    message: mappedError.message,
                    data: mappedError.data
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeLoginOTPRequestLoader(_ param: LoginOTPRequestParam) -> API<LoginOTPRequestData, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/otp")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<LoginOTPRequestData>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(
                    code: mappedError.code,
                    message: mappedError.message,
                    data: mappedError.data
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

// MARK: UIViewController Factory
private extension AppDelegate {
    func makeLoginViewController(account: String?) -> UIViewController {
        let loaders = LoginUIComposer.Loader(
            loginLoader: makeLoginLoader
        )
        
        let callbacks = LoginUIComposer.Callback(
            onSuccessLogin: { [weak self] response in
                KKCache.common.remove(key: .trendingCache)
                self?.saveLogin(response)
                
                if let accountId = response.accountID {
                    self?.loadProfile(accountId)
                }
            },
            onFailedLogin: { [weak self] error in
                KKCache.common.remove(key: .trendingCache)
                self?.showLoginError(error: error)
            }
        )
        
        let loginViewController = LoginUIComposer.composeWith(
            account: account,
            loaders: loaders,
            callbacks: callbacks,
            delegate: self
        )
        
        return loginViewController
    }
    
    func makeLoginOTPRequestViewController() -> UIViewController {
        let callbacks = LoginOTPRequestUIComposer.Callback(
            onSuccessRequestOTP: navigateToLoginWithOTPViewController
        )
        
        let controller = LoginOTPRequestUIComposer.composeWith(
            publisher: makeLoginOTPRequestLoader,
            callbacks: callbacks
        )
        return controller
    }
    
    func makeLoginWithPasswordViewController(phoneNumber: Phone) -> UIViewController {
        let parameter = LoginPasswordUIComposer.Parameter(phoneNumber: phoneNumber)
        let events = LoginPasswordUIComposer.Event(didTapForgotPassword: showForgotPasswordPage)
        let callbacks = LoginPasswordUIComposer.Callback(
            onSuccessLogin: { [weak self] response in
                KKCache.common.remove(key: .trendingCache)
                self?.saveLogin(response)
                
                if let accountId = response.accountID {
                    self?.loadProfile(accountId)
                }
            },
            onFailedLogin: { [weak self] error in
                KKCache.common.remove(key: .trendingCache)
                self?.showLoginError(error: error)
            }
        )
        let controller = LoginPasswordUIComposer.composeWith(
            loader: makeLoginLoader,
            parameter: parameter,
            events: events,
            callbacks: callbacks
        )
        return controller
    }
    
    func makeLoginWithOTPViewController(parameter: LoginWithOTPUIComposer.Parameter) -> UIViewController {
        let loaders = LoginWithOTPUIComposer.Loader(
            loginLoader: makeLoginLoader,
            otpRequestLoader: makeLoginOTPRequestLoader
        )
        
        let event = LoginWithOTPUIComposer.Event(
            onTapRegister: { [weak self] phone, code in
                self?.navigateToRegisterPhoneStepsAfterLoginViewController(phone: phone, otpCode: code)
            },
            didTapLoginWithPassword: navigateToLoginWithPasswordViewController
        )
        
        let callback = LoginWithOTPUIComposer.Callback(
            onSuccessLogin: { [weak self] response in
                KKCache.common.remove(key: .trendingCache)
                self?.saveLogin(response)
                
                if let accountID = response.accountID {
                    self?.loadProfile(accountID)
                }
            }
        )
        
        let controller = LoginWithOTPUIComposer.composeWith(
            loaders: loaders,
            parameter: parameter,
            event: event,
            callback: callback
        )
        
        return controller
    }
}

// MARK: Routing
extension AppDelegate {
    
    //MARK: Private
    private func showLoginOptions() {
        
        guard getToken() == nil else { return }
        
        NotificationCenter.default.post(name: .shouldPausePlayer, object: nil)
        
        let loginOptions = LoginOptionsViewController()
        loginOptions.didTapLogin = { [weak self] in
            self?.navigateToLoginContainerViewController()
        }
        loginOptions.onWillDismiss = {
            NotificationCenter.default.post(name: .shouldResumePlayer, object: nil)
        }
        loginOptions.didTapRegister = navigateToRegisterContainerViewController
        loginOptions.didTapPrivacyPolicy = navigateToPrivacyPolicyWebViewController
        loginOptions.didTapTermsAndCondition = navigateToTermsConditionWebViewController
        
        let configuration = PresentationUIConfiguration(
            cornerRadius: 16,
            corners: [
                .layerMaxXMinYCorner,
                .layerMinXMinYCorner
            ]
        )
        let size = PresentationSize(height: .custom(value: UIScreen.main.bounds.height - 100))
        
        presentWithCoverAnimation(
            configuration: configuration,
            size: size,
            loginOptions
        )
    }
    
    private func navigateToLoginWithPasswordViewController(phoneNumber: Phone) {
        let destination = makeLoginWithPasswordViewController(phoneNumber: phoneNumber)
        pushOnce(destination)
    }
    
    private func navigateToPrivacyPolicyWebViewController() {
        let url = URL(string: "https://kipaskipas.com/kebijakan-privasi-kipaskipas/")
        let controller = ProgressWebViewController(url: url)
        controller.title = "Kebijakan Privasi"
        controller.configureDismissablePresentation()
        
        let destination = UINavigationController(rootViewController: controller)
        presentWithSlideAnimation(destination)
    }
    
    private func navigateToTermsConditionWebViewController() {
        let url = URL(string: "https://kipaskipas.com/syarat-dan-ketentuan-kipaskipas/")
        let controller = ProgressWebViewController(url: url)
        controller.title = "Syarat & Ketentuan"
        controller.configureDismissablePresentation()
        
        let destination = UINavigationController(rootViewController: controller)
        presentWithSlideAnimation(destination)
    }
    
    
    // MARK: Shared
    func navigateToLoginContainerViewController(animated: Bool = true) {
        let destination = LoginContainerViewController(
            models: [
                .init(viewController: makeLoginOTPRequestViewController(), title: "Telepon"),
                .init(viewController: makeLoginViewController(account: nil), title: "Alamat email/nama pengguna")
            ]
        )
        destination.configureDismissablePresentation()
        
        let navigation = UINavigationController(rootViewController: destination)
        presentWithSlideAnimation(navigation)
    }
    
    func navigateToLoginWithOTPViewController(_ phone: Phone, _ interval: TimeInterval) {
        let destination = makeLoginWithOTPViewController(parameter: .init(phoneNumber: phone, interval: interval))
        pushOnce(destination, animated: false)
    }
    
    func navigateToLoginViewController(account: String?) {
        let destination = makeLoginViewController(account: account)
        pushOnce(destination)
    }
    
    private func loadProfile(_ userId: String) {
        profileAdapter.loadProfile(userId, onSuccessLoadProfile: { [weak self] profile in
            self?.profileStore.insert(profile)
            self?.configureCallFeature()
//            self?.updateSendbirdMetadata()
            self?.showNextViewController()
            KKCache.credentials.save(string: profile.photo ?? "", key: .userPhotoProfile)
        }, onFailedLoadProfile: { [weak self] _ in
            self?.showNextViewController()
        })
    }
    
    func makeProfileLoader(_ userId: String) -> API<LoginProfileData, AnyError> {
        return authenticatedHTTPClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/profile/\(userId)")
                    .build()
            )
            .tryMap(Mapper<LoginProfileData>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(
                    code: mappedError.code,
                    message: mappedError.message,
                    data: mappedError.data
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

extension AppDelegate: LoginViewControllerDelegate {
    
    func showForgotPasswordPage() {
        let alert = UIAlertController(
            title: "Reset kata sandi dengan:",
            message: nil,
            preferredStyle: .alert
        )
        alert.setTitleFont(.roboto(.medium, size: 17))
        
        let phone = UIAlertAction(
            title: "Nomor telepon",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            navigateToResetPasswordWithPhoneViewController()
        }
        
        let email = UIAlertAction(
            title: "Alamat email",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                navigateToResetPasswordWithEmailViewController()
            }
        
        let back = UIAlertAction(
            title: "Batalkan",
            style: .cancel
        )
        
        alert.overrideUserInterfaceStyle = .light
        alert.addAction(phone)
        alert.addAction(email)
        alert.addAction(back)
        alert.setBackgroundColor(color: .white)
        
        presentOnce(alert)
    }
}
