//
//  SceneDelegate+Login.swift
//  KipasKipasVerificationIdentityApp
//
//  Created by DENAZMI on 05/06/24.
//

import UIKit
import Combine
import KipasKipasLogin
import KipasKipasLoginiOS
import KipasKipasNetworking
import KipasKipasShared

extension SceneDelegate {
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
                return .init(
                    code: mappedError.code,
                    message: mappedError.message,
                    data: mappedError.data
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func setUserLoginSession(from data: LoginResponse) {
        tokenStore.insert(data.localToken) { _ in }
        saveUserLoggedIn(from: data)
    }
    
    func makeLoginViewController() -> UIViewController {
        let loaders = LoginUIComposer.Loader(
            loginLoader: makeLoginLoader
        )
        
        let callbacks = LoginUIComposer.Callback(
            onSuccessLogin: { [weak self] loginResponse in
                guard let self = self, let window = self.window else { return }
                self.setUserLoginSession(from: loginResponse)
                self.configureRootViewController(in: window)
            },
            onFailedLogin: { dump($0) }
        )
        
        let controller = LoginUIComposer.composeWith(
            account: nil,
            loaders: loaders,
            callbacks: callbacks,
            delegate: Delegation()
        )
        
        return controller
    }
}

private extension LoginResponse {
    var localToken: LocalTokenItem {
        var second = expiresIn ?? 1234
        second -= 43200
        
        let expiredDate = TokenHelper.addSecondToCurrentDate(second: second)
        
        return .init(
            accessToken: accessToken ?? "",
            refreshToken: refreshToken ?? "",
            expiresIn: expiredDate
        )
    }
}

extension SceneDelegate: LoginViewControllerDelegate {
    func showRegisterPage() {}
    func showForgotPasswordPage() {}
}

extension UserDefaults {
    private enum Key: String {
        case hasRunBefore
    }
    
    var hasRunBefore: Bool {
        return bool(forKey: Key.hasRunBefore.rawValue)
    }
    
    func hasRun() {
        setValue(true, forKey: Key.hasRunBefore.rawValue)
    }
}

private class Delegation: LoginViewControllerDelegate {
    func showRegisterPage() {}
    func showForgotPasswordPage() {}
}
