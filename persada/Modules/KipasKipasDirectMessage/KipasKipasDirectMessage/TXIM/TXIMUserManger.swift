//
//  TXIMUserManger.swift
//  KipasKipasDirectMessage
//
//  Created by MissYasiky on 2024/3/12.
//

import Foundation
import ImSDK_Plus

let TXIMUserErrorDomain = "com.kipaskipas.TXIMUserManager"

public protocol TXIMUserMangerDelegate {
    func onIMUserKickedOffline()
    func onIMUserSigExpired()
}

public final class TXIMUserManger: NSObject {
    
    private var appID: String? = nil
    public static let shared = TXIMUserManger()
    public var delegate: TXIMUserMangerDelegate?
    public var currentUserId: String? {
        imManager.getLoginUser()
    }
    
    private(set) lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
    }()
    
    public func initSDK(appId: String) {
        imManager.add(self)
        appID = appId
        initIMSDK()
    }
    
    private func initIMSDK() {
        guard appID != nil else {
            print("【DM】cannot init SDK because appID is nil")
            return
        }
        let initSDK = imManager.initSDK((Int32(appID!) ?? 0), config: V2TIMSDKConfig())
        print("【DM】init SDK \(initSDK ? "success" : "failure") with appId \(appID ?? "null")")
    }
    
    public func login(_ userId: String, userSig: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if imManager.getLoginStatus() == .STATUS_LOGINED && userId == currentUserId {
            completion(.success(()))
            return
        }
        
        if imManager.getLoginStatus() != .STATUS_LOGOUT {
            logout {}
        }
        
        imManager.login(userId, userSig: userSig) {
            completion(.success(()))
            print("【DM】im login success")
        } fail: { [weak self] code, desc in
            let str = "IM login failed (\(code))"
            let error = NSError(domain: TXIMUserErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: str])
            completion(.failure(error))
            print("【DM】im login failure \(desc ?? "")(\(code))")
            
            if code == 6013 {
                self?.initIMSDK()
            }
        }
    }
    
    public func logout(completion: @escaping () -> Void) {
        if imManager.getLoginStatus() == .STATUS_LOGOUT {
            return
        }
        
        imManager.logout {
            completion()
            print("【DM】im logout success")
        } fail: { code, desc in
            completion()
            print("【DM】im logout failure \(desc ?? "")(\(code))")
        }
    }
    
    public func updateUserInfo(nickName: String?, profileURL: String?, isVerified: Bool) {
        updateUserInfo(nickName: nickName, profileURL: profileURL, isVerified: isVerified) { _ in}
    }
    
    public func updateUserInfo(nickName: String?, profileURL: String?, isVerified: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let info = V2TIMUserFullInfo()
        info.nickName = nickName
        info.faceURL = profileURL
        
        let verified: String = isVerified ? "1" : "0"
        if let data = verified.data(using: .utf8) {
            info.customInfo = ["verified" :  data]
        }
        
        imManager.setSelfInfo(info) {
            completion(.success(()))
            print("【DM】im set user info success")
        } fail: { code, desc in
            let error = NSError(domain: TXIMUserErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: (desc ?? "")])
            completion(.failure(error))
            print("【DM】im set user info failure \(desc ?? "")(\(code))")
        }
    }

    public func getUsersInfo(_ userIDList: [String], success: @escaping ([TXIMUser]) -> Void, failure: @escaping (Error) -> Void) {
        guard !userIDList.isEmpty else {
            success([])
            return
        }

        imManager.getUsersInfo(userIDList) { userInfoList in
            if let userInfoList {
                let userList = userInfoList.map{ TXIMUser(user: $0) }
                NotificationCenter.default.post(name: .init("getUserInfo"), object: userList)
                success(userList)
            } else {
                let code: Int = 101
                let desc = "data is null"
                let error = NSError(domain: TXIMUserErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: desc])
                failure(error)
                print("【DM】im get user info failure \(desc)(\(code))")
            }
        } fail: { code, desc in
            let error = NSError(domain: TXIMUserErrorDomain, code: Int(code), userInfo: [NSLocalizedDescriptionKey: (desc ?? "")])
            failure(error)
            print("【DM】im get user info failure \(desc ?? "")(\(code))")
        }
    }
}

// MARK: - V2TIMSDKListener
extension TXIMUserManger: V2TIMSDKListener {
    public func onKickedOffline() {
        self.delegate?.onIMUserKickedOffline()
    }
    
    public func onUserSigExpired() {
        self.delegate?.onIMUserSigExpired()
    }
}
