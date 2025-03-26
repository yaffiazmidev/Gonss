//
//  AppDelegate+CallAuthenticator.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import KipasKipasCall
import KipasKipasDirectMessage

extension AppDelegate {
    func configureCallFeature() {
        guard getToken() != nil else { return }
        
        DirectMessageCallServiceManager.configure(
            SDKAPPID: Int(SDKAPPID) ?? 0,
            authenticator: callAuthenticator,
            loader: callLoader,
            requestGenerateUserSig: generateCallUserSig,
            requestLoadUserData: loadUser,
            requestPushInfo: generatePushInfo
        )
        
        if let profile = profileStore.retrieve() {
            loginCallFeature(
                userId: profile.id ?? "",
                fullname: profile.name ?? "",
                pictureUrl: profile.photo
            )
        } else {
            let id = getIdUser()
            if !id.isEmpty {
                loginCallFeature(userId: id, fullname: "", pictureUrl: "")
            }
        }
    }
    
    func loginCallFeature(userId: String, fullname: String, pictureUrl: String?, completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
        let userSig = TencentUserSig.genTestUserSig(userId)
        let request = TUICallLoginAuthenticatorRequest(
            fullName: fullname,
            pictureUrl: pictureUrl ?? "",
            userId: userId,
            sdkAppId: UInt32(SDKAPPID) ?? 0,
            userSig: userSig
        )
        
        callAuthenticator.login(with: request) { [weak self] result in
            guard let self = self else { return }
            completion?(result)
            self.didCallLogin(with: result)
        }
    }
}

// MARK: Authenticator Handler
private extension AppDelegate {
    private func didCallLogin(with result: Swift.Result<Void, Error>) {
        switch result {
        case .success(_):
            print("Call Feature: Success Login")
            break
        case .failure(let failure):
            print("Call Feature: Failure Login", failure.localizedDescription)
            break
        }
    }
    
    private func didCallLogout(with result: Swift.Result<Void, Error>) {
        guard let window = window else { return }
        switch result {
        case .success(_):
            print("Call Feature: Success Logout")
            break
        case .failure(let failure):
            print("Call Feature: Failure Logout", failure.localizedDescription)
            break
        }
    }
}

// MARK: - Helper
private extension AppDelegate {
    private func generateCallUserSig(userId: String) -> String {
        TencentUserSig.genTestUserSig(userId)
    }
    
    private func generatePushInfo() -> CallLoaderRequestPushInfo {
        return CallLoaderRequestPushInfo(
            title: "Title Test",
            description: "Description Test",
            iosPushType: .voIP,
            ignoreIOSBadge: false,
            iOSSound: "phone_ringing.mp3",
            androidSound: "phone_ringing",
            androidVIVOClassification: 1,
            androidHuaWeiCategory: "IM"
        )
    }
    
    private func loadUser(by id: String, with token: String, onSuccess: @escaping LoadUserDataCompletion) {
        
        let request = CallProfileDataLoaderRequest(userId: id)
        callProfileLoader.load(request: request) { [weak self] result in
            guard self != nil else {
                print("Call Feature: Failure Load User Data")
                return
            }
            
            switch result {
            case .failure(let error):
                print("Call Feature: Failure Load Profile")
            case .success(let response):
                print("Call Feature: Success Load Profile")
                onSuccess(response.id, response.name, response.photo)
            }
        }
    }
}
