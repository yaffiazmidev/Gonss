import UIKit
import Combine
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasRegister
import KipasKipasRegisteriOS
import KipasKipasShared

extension SceneDelegate {
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
    
    private func makeVerifyOTPLoader(_ param: RegisterVerifyOTPParam) -> API<RegisterVerifyOTPData, AnyError>{
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
            .map { data in return data.url }
            .mapError({ _ in
                return .init(
                    code: "0000",
                    message: "Upload foto tidak berhasil"
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeRegisterLoader(_ param: RegisterUserParam) -> API<RegisterResponse, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/registers")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap { (data, response) in
                guard response.isOK, let root = try? JSONDecoder().decode(RegisterResponse.self, from: data) else {
                    throw KKNetworkError.invalidData
                }
                return root
            }
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
    
    func makeRequestOTPRegistrationViewController() -> UIViewController {
        let callbacks = RegisterPhoneUIComposer.Callback(
            onSuccessRequestOTP: navigateToRegisterPhoneStepsViewController,
            redirectToLoginWithOTP: { _ in }
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
        let parameter = RegisterPhotoUIComposer.Parameter(referralCode: "")
        let callback = RegisterPhotoUIComposer.Callback(
            onRegistrationSuccess: { response in
                print("[BEKA] Registration success", response)
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
    
    func makeRegisterEmailViewController() -> UIViewController {
        let callbacks = RegisterEmailUIComposer.Callback(
            onAccountAvailable: navigateToRegisterEmailStepsViewController,
            onAccountNotAvailable: { print("[BEKA] account is not available", $0) }
        )
        let controller = RegisterEmailUIComposer.composeWith(
            loader: makeAccountAvailabilityLoader,
            callbacks: callbacks
        )
        return controller
    }
    
    func makeBirthdayPickerViewController() -> StepsController {
        return BirthdayPickerViewController()
    }
    
    func makePasswordRegistrationController() -> StepsController {
        return RegisterPasswordViewController()
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
        return controller
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
        return controller
    }
}

// MARK: Routing
extension SceneDelegate {
    func navigateToRegisterEmailStepsViewController(email: String) {
        let destination = makeRegisterEmailStepsViewController(email: email)
        navigationController.pushViewController(destination, animated: true)
    }
    
    func navigateToRegisterPhoneStepsViewController(phone: String, countdown: Int) {
        let destination = makeRegisterPhoneStepsViewController(phone: phone, countdown: countdown)
        navigationController.pushViewController(destination, animated: true)
    }
}
