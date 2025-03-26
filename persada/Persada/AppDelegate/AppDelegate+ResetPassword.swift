import UIKit
import Combine
import KipasKipasShared
import KipasKipasResetPassword
import KipasKipasResetPasswordiOS
import KipasKipasNetworking
import KipasKipasLogin

// MARK: Shared
extension AppDelegate {
    func navigateToResetPasswordWithPhoneViewController() {
        let destination = makeResetPasswordWithPhoneViewController()
        pushOnce(destination)
    }
    
    func navigateToResetPasswordWithEmailViewController() {
        let destination = makeResetPasswordEmailViewController()
        pushOnce(destination)
    }
}

// MARK: Loaders
private extension AppDelegate {
    func makeResetPasswordRequestOTPLoader(_ param: ResetPasswordRequestOTPParam) -> API<ResetPasswordOTPData, AnyError> {
        let isMail = param.email != nil
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/forgot-password\(isMail ? "/mail" : "")/request")
                    .method(.POST)
                    .body(param.email ?? param.phone)
                    .build()
            )
            .tryMap(Mapper<ResetPasswordOTPData>.map)
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
    
    func makeResetPasswordVerifyOTPLoader(_ param: ResetPasswordVerifyOTPParam) -> API<ResetPasswordVerifyOTPData, AnyError> {
        let isUsingUniversalLink = param.emailLink != nil
        let param: Encodable! = param.email ?? param.phone ?? param.emailLink
        
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/forgot-password/verify/\(isUsingUniversalLink ? "mail" : "otp")")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<ResetPasswordVerifyOTPData>.map)
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
    
    func makeResetPasswordLoader(_ param: ResetPasswordVerifyOTPResponse) -> API<ResetPasswordResponse, AnyError> {
        let isEmail = param.email != nil
        
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/forgot-password\(isEmail ? "/mail" : "")")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<ResetPasswordResponse>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(
                    code: mappedError.code,
                    message: mappedError.message
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeLoginLoader(_ param: ResetPasswordLoginParam) -> API<ResetPasswordLoginResponse, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/login")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<ResetPasswordLoginResponse>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(code: mappedError.code, message: mappedError.message)
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

// MARK: View-controller factory
private extension AppDelegate {
    func makeResetPasswordWithPhoneViewController() -> UIViewController {
        let callbacks = ResetPasswordPhoneUIComposer.Callback(
            onSuccessRequestOTP: navigateToResetPasswordVerifyOTPViewController
        )
        
        let controller = ResetPasswordPhoneUIComposer.composeWith(
            loader: makeResetPasswordRequestOTPLoader,
            callbacks: callbacks
        )
        return controller
    }
    
    func makeResetPasswordEmailViewController() -> UIViewController {
        let callbacks = ResetPasswordEmailUIComposer.Callback(
            onSuccessRequestOTP: navigateToResetPasswordVerifyOTPViewController
        )
        let controller = ResetPasswordEmailUIComposer.composeWith(
            loader: makeResetPasswordRequestOTPLoader,
            callbacks: callbacks
        )
        return controller
    }
    
    func makeResetPasswordVerifyOTPViewController(param: ResetPasswordParameter) -> UIViewController {
        let loaders = ResetPasswordVerifyOTPUIComposer.Loader(
            verifyOTPLoader: makeResetPasswordVerifyOTPLoader,
            requestOTPLoader: makeResetPasswordRequestOTPLoader
        )
        let callback = ResetPasswordVerifyOTPUIComposer.Callback(
            onSuccessVerifyOTP: navigateToResetPasswordViewController
        )
        let controller = ResetPasswordVerifyOTPUIComposer.composeWith(
            loaders: loaders,
            parameter: param,
            callback: callback
        )
        
        return controller
    }
    
    func makeResetPasswordViewController(param: ResetPasswordUIComposer.Parameter) -> UIViewController {
        let loaders = ResetPasswordUIComposer.Loader(
            resetPasswordLoader: makeResetPasswordLoader,
            loginLoader: makeLoginLoader
        )
        let callback = ResetPasswordUIComposer.Callback(
            onSuccessLogin: { [weak self] response in
                guard let self = self else { return }
                saveCredentials(from: response)
                
                if let accountID = response.accountID {
                    loadProfile(accountID)
                }
            },
            onFailedLogin: { [weak self] in
                guard let self = self else { return }
                showHome(animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigateToLoginContainerViewController(animated: false)
                }
            }
        )
        let controller = ResetPasswordUIComposer.composeWith(
            loaders: loaders,
            parameter: param,
            callback: callback
        )
        
        return controller
    }
    
    func saveCredentials(from response: ResetPasswordLoginResponse) {
        let credentials = LoginResponse(
            accessToken: response.accessToken,
            tokenType: "bearer",
            loginResponseRefreshToken: response.refreshToken,
            expiresIn: response.expiresIn,
            scope: nil,
            userNo: nil,
            userName: response.userName,
            userEmail: response.userEmail,
            userMobile: response.userMobile,
            accountID: response.accountID,
            authorities: [],
            appSource: nil,
            code: nil,
            timelapse: nil,
            role: response.role,
            jti: nil,
            token: response.accessToken,
            refreshToken: response.refreshToken
        )
        saveLogin(credentials)
    }
    
    func loadProfile(_ userId: String) {
        profileAdapter.loadProfile(userId, onSuccessLoadProfile: { [weak self] profile in
            self?.profileStore.insert(profile)
            self?.configureCallFeature()
//            self?.updateSendbirdMetadata()
            self?.showHome()
            KKCache.credentials.save(string: profile.photo ?? "", key: .userPhotoProfile)
        }, onFailedLoadProfile: { [weak self] _ in
            self?.showHome()
        })
    }
    
    func showHome(animated: Bool = true) {
        clearNotifsNav()
        let mainTabController = MainTabController()
        mainTabController.notifsNavigate?.configureNotif()
        
        DispatchQueue.main.async {
            if animated {
                self.window?.switchRootWithPushTo(viewController: mainTabController)
            } else {
                self.window?.switchRootViewController(mainTabController, animated: animated)
            }
        }
    }
}

// MARK: Routing
private extension AppDelegate {
    func navigateToResetPasswordVerifyOTPViewController(param: ResetPasswordParameter) {
        let destination = makeResetPasswordVerifyOTPViewController(param: param)
        pushOnce(destination)
    }
    
    func navigateToResetPasswordViewController(
        _ response: ResetPasswordVerifyOTPResponse,
        param: ResetPasswordParameter
    ) {
        let destination = makeResetPasswordViewController(
            param: .init(
                response: response,
                param: param
            )
        )
        pushOnce(destination)
    }
}
