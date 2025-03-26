import UIKit
import Combine
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasRegister
import KipasKipasRegisteriOS
import KipasKipasLogin
import FeedCleeps
import KipasKipasPaymentInAppPurchase
import KipasKipasDonationCart

// MARK: Loaders
extension AppDelegate {
    private func makeRequestOTPLoader(_ param: RegisterRequestOTPParam) -> API<RegisterRequestOTPData, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/otp")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<RegisterRequestOTPData>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return .init(
                    code: mappedError.code,
                    message: mappedError.message,
                    data: mappedError.data
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeVerifyOTPLoader(_ param: RegisterVerifyOTPParam) -> API<RegisterVerifyOTPData, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/otp/verification")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<RegisterVerifyOTPData>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return .init(
                    code: mappedError.code,
                    message: mappedError.message,
                    data: mappedError.data
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeAccountAvailabilityLoader(param: RegisterAccountAvailabilityParam) -> API<RegisterAccountAvailabilityResponse, AnyError> {
        
        var query: URLQueryItem {
            switch param {
            case let .username(value):
                return .init(name: "username", value: value)
            case let .email(value):
                return .init(name: "email", value: value)
            }
        }
        
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/registers/accounts/exists-by")
                    .queries([query])
                    .build()
            )
            .tryMap(Mapper<RegisterAccountAvailabilityResponse>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return .init(
                    code: mappedError.code,
                    message: mappedError.message
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeUploadPhotoLoader(_ param: RegisterUploadPhotoParam) -> API<String, AnyError> {
        return mediaUploader
            .upload(request: MediaUploaderRequest(media: param.imageData, ext: "jpeg"))
            .map { data in return data.tmpUrl }
            .mapError({ _ in
                return .init(
                    code: "0000",
                    message: "Upload foto tidak berhasil. Coba lagi nanti."
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeRegisterLoader(_ param: RegisterUserParam) -> API<RegisterResponse, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/registers")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<RegisterResponse>.map)
            .mapError { error in
                let mappedError = MapperError.map(error)
                return .init(
                    code: mappedError.code,
                    message: mappedError.message
                )
            }
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeVerifyEmailLoader(_ param: RegisterVerifyEmailParam) -> API<EmptyData, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/email/verification")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<EmptyData>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return .init(
                    code: mappedError.code,
                    message: mappedError.message,
                    data: mappedError.data
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

extension AppDelegate {
    func makeRequestOTPRegistrationViewController() -> UIViewController {
        let callbacks = RegisterPhoneUIComposer.Callback(
            onSuccessRequestOTP: navigateToRegisterPhoneStepsViewController,
            redirectToLoginWithOTP: { [weak self] phone in
                self?.navigateToLoginWithOTPViewController(phone, 0)
            }
        )
        let viewController = RegisterPhoneUIComposer.composeWith(
            loader: makeRequestOTPLoader,
            callbacks: callbacks
        )
        return viewController
    }
    
    func makeVerifyOTPRegistrationViewController() -> StepsController {
        let viewController = RegisterVerifyOTPUIComposer.composeWith(
            requestOTPLoader: makeRequestOTPLoader,
            verifyOTPLoader: makeVerifyOTPLoader
        )
        return viewController
    }
    
    func makeUsernameRegistrationViewController() -> StepsController {
        let viewController = RegisterUsernameUIComposer.composeWith(
            loader: makeAccountAvailabilityLoader
        )
        return viewController
    }
    
    func makeProfilePhotoPickerViewController() -> StepsController {
        let referralCode = DataCache.instance.readString(forKey: "REFFCODE") ?? ""
        let parameter = RegisterPhotoUIComposer.Parameter(referralCode: referralCode)
        let callback = RegisterPhotoUIComposer.Callback(
            onRegistrationSuccess: {[weak self] response in
                guard let self = self else { return }
                saveCredentials(from: response)
                
                if let accountId = response.accountId {
                    loadProfile(accountId)
                }
            }
        )
        let viewController = RegisterPhotoUIComposer.composeWith(
            parameter: parameter,
            callback: callback,
            uploadPublisher: makeUploadPhotoLoader,
            registerLoadPublisher: makeRegisterLoader
        )
        
        return viewController
    }
    
    func makeBirthdayPickerViewController() -> StepsController {
        return BirthdayPickerViewController()
    }
    
    func makePasswordRegistrationController() -> StepsController {
        return RegisterPasswordViewController()
    }
    
    func makeRegisterPhoneStepsViewController(phone: String, countdown: Int) -> UIViewController {
        let data = RegisterData(
            otpExpirationDuration: countdown,
            phoneNumber: phone
        )
        
        let controller = RegisterStepsContainerViewController(
            steps: [
                makeVerifyOTPRegistrationViewController(),
                makeBirthdayPickerViewController(),
                makePasswordRegistrationController(),
                makeUsernameRegistrationViewController()
            ],
            data: data
        )
        controller.register = registerWithPhone
        return controller
    }
    
    func makeRegisterPhoneStepsAfterLoginViewController(phone: String, otpCode: String) -> UIViewController {
        let data = RegisterData(
            otpCode: otpCode,
            phoneNumber: phone
        )
        
        let controller = RegisterStepsContainerViewController(
            steps: [
                makeBirthdayPickerViewController(),
                makePasswordRegistrationController(),
                makeUsernameRegistrationViewController()
            ],
            data: data
        )
        controller.register = registerWithPhone
        return controller
    }
    
    func makeRegisterContainerViewController() -> UIViewController {
        let controller = RegisterContainerViewController(
            models: [
                .init(viewController: makeRequestOTPRegistrationViewController(), title: "Telepon"),
                .init(viewController: makeRegisterEmailViewController(), title: "Email")
            ]
        )
        return controller
    }
    
    func makeRegisterEmailViewController() -> UIViewController {
        let callbacks = RegisterEmailUIComposer.Callback(
            onAccountAvailable: navigateToRegisterEmailStepsViewController,
            onAccountNotAvailable: navigateToLoginViewController
        )
        let controller = RegisterEmailUIComposer.composeWith(
            loader: makeAccountAvailabilityLoader,
            callbacks: callbacks
        )
        return controller
    }
    
    func makeRegisterEmailStepsViewController(email: String) -> UIViewController {
        let data = RegisterData(email: email)
        let controller = RegisterStepsContainerViewController(
            steps: [
                makePasswordRegistrationController(),
                makeBirthdayPickerViewController(),
                makeUsernameRegistrationViewController()
            ],
            data: data
        )
        controller.register = registerWithEmail
        return controller
    }
    
    private func saveCredentials(from response: RegisterResponse) {
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
            accountID: response.accountId,
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
    
    private func loadProfile(_ userId: String) {
        profileAdapter.loadProfile(
            userId,
            onSuccessLoadProfile: { [weak self] profile in
                self?.profileStore.insert(profile)
                self?.configureCallFeature()
//                self?.updateSendbirdMetadata()
                self?.showHome()
                KKCache.credentials.save(string: profile.photo ?? "", key: .userPhotoProfile)
            }, onFailedLoadProfile: { [weak self] _ in
                self?.showHome()
            })
    }
    
    private func registerWithEmail(_ data: RegisterData) {
        let param = RegisterUserParam(
            name: data.username,
            mobile: nil,
            password: data.password,
            photo: nil,
            username: data.username,
            otpCode: nil,
            birthDate: data.birthDate,
            gender: nil,
            deviceId: UIDevice.current.identifierForVendor?.uuidString,
            referralCode: DataCache.instance.readString(forKey: "REFFCODE") ?? "",
            email: data.email
        )
        registerAdapter.register(
            with: param,
            onSuccessRegister: {
                [weak self] response in
                guard let self = self else { return }
                saveCredentials(from: response)
                
                if let accountId = response.accountId {
                    loadProfile(accountId)
                }
            },
            onFailedRegister: { [weak self] error in
                self?.showToast(
                    message: "Registration failed. Code: \(error.error?.message ?? "Undefined")"
                )
            }
        )
    }
    
    private func registerWithPhone(_ data: RegisterData) {
        let param = RegisterUserParam(
            name: data.username,
            mobile: data.phoneNumber,
            password: data.password,
            photo: nil,
            username: data.username,
            otpCode: data.otpCode,
            birthDate: data.birthDate,
            gender: nil,
            deviceId: UIDevice.current.identifierForVendor?.uuidString,
            referralCode: DataCache.instance.readString(forKey: "REFFCODE") ?? "",
            email: nil
        )
        registerAdapter.register(
            with: param,
            onSuccessRegister: {
                [weak self] response in
                guard let self = self else { return }
                saveCredentials(from: response)
                
                if let accountId = response.accountId {
                    loadProfile(accountId)
                }
            },
            onFailedRegister: { [weak self] error in
                self?.showToast(
                    message: "Registration failed. Reason: \(error.error?.message ?? "Undefined")"
                )
            }
        )
    }
    
    private func showHome() {
        clearNotifsNav()
        let mainTabController = MainTabController()
        mainTabController.notifsNavigate?.configureNotif()
        
        DispatchQueue.main.async {
            self.window?.switchRootWithPushTo(viewController: mainTabController)
        }
    }
}

// MARK: Routing
extension AppDelegate {
    func navigateToRegisterContainerViewController() {
        let destination = makeRegisterContainerViewController()
        destination.configureDismissablePresentation()
        
        let navigation = UINavigationController(rootViewController: destination)
        presentWithSlideAnimation(navigation)
    }
    
    func navigateToRegisterEmailStepsViewController(email: String) {
        let destination = makeRegisterEmailStepsViewController(email: email)
        pushOnce(destination)
    }
    
    func navigateToRegisterPhoneStepsViewController(phone: String, countdown: Int) {
        let destination = makeRegisterPhoneStepsViewController(phone: phone, countdown: countdown)
        pushOnce(destination)
    }
    
    func navigateToRegisterPhoneStepsAfterLoginViewController(phone: String, otpCode: String) {
        let destination = makeRegisterPhoneStepsAfterLoginViewController(phone: phone, otpCode: otpCode)
        pushOnce(destination)
    }
}
