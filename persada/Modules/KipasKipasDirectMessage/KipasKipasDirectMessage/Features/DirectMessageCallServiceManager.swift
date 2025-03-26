//
//  DirectMessageCallServiceManager.swift.swift
//  KipasKipasDirectMessage
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/01/24.
//

import Foundation
import KipasKipasCall

public typealias LoadUserDataCompletion = (_ userId: String?, _ fullname: String?, _ pictureUrl: String?) -> Void

public final class DirectMessageCallService: NSObject {
    
    public let SDKAPPID: Int
    public let authenticator: CallAuthenticator
    public let loader: CallLoader
    public let requestGenerateUserSig: (String) -> String
    public let requestLoadUserData: (_ userId: String,_ token: String, _ completion: @escaping LoadUserDataCompletion) -> Void
    public let requestPushInfo: (() -> (CallLoaderRequestPushInfo))?
    
    public init(
        SDKAPPID: Int,
        authenticator: CallAuthenticator,
        loader: CallLoader,
        requestGenerateUserSig: @escaping (String) -> String,
        requestLoadUserData: @escaping (_ userId: String, _ token: String, _ completion: @escaping LoadUserDataCompletion) -> Void,
        requestPushInfo: (() -> (CallLoaderRequestPushInfo))?
    ) {
        self.SDKAPPID = SDKAPPID
        self.authenticator = authenticator
        self.loader = loader
        self.requestGenerateUserSig = requestGenerateUserSig
        self.requestLoadUserData = requestLoadUserData
        self.requestPushInfo = requestPushInfo
    }
}

public class DirectMessageCallServiceManager {
    
    private static var _instance: DirectMessageCallServiceManager?
    private static let lock = NSLock()
    
    private(set) public var service: DirectMessageCallService!
    
    private var _SDKAPPID: Int!
    private var _authenticator: CallAuthenticator!
    private var _loader: CallLoader!
    private var _requestGenerateUserSig: ((_ userId: String) -> (String))!
    private var _requestLoadUserData: ((_ userId: String, _ token: String, _ completion: @escaping LoadUserDataCompletion) -> Void)!
    private var _requestPushInfo: (() -> (CallLoaderRequestPushInfo))?
    
    public var SDKAPPID: Int {
        return service.SDKAPPID
    }
    
    public var authenticator: CallAuthenticator! {
        return service.authenticator
    }
    
    public var loader: CallLoader! {
        return service.loader
    }
    
    public var requestGenerateUserSig: ((_ userId: String) -> String)! {
        return service.requestGenerateUserSig
    }
    
    public var requestLoadUserData: ((_ userId: String, _ token: String, _ completion: @escaping LoadUserDataCompletion) -> Void)! {
        return service.requestLoadUserData
    }
    
    public var requestPushInfo: (() -> (CallLoaderRequestPushInfo))? {
        return service.requestPushInfo
    }
    
    public static var instance: DirectMessageCallServiceManager {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = DirectMessageCallServiceManager()
            }
        }
        return _instance!
    }
    
    private init(){}
    
    public class func configure(
        SDKAPPID: Int,
        authenticator: CallAuthenticator,
        loader: CallLoader,
        requestGenerateUserSig: @escaping ((String) -> String),
        requestLoadUserData: @escaping (_ userId: String, _ token: String, _ completion: @escaping LoadUserDataCompletion) -> Void,
        requestPushInfo: (() -> (CallLoaderRequestPushInfo))? = nil
    ) {
        instance.service = DirectMessageCallService(
            SDKAPPID: SDKAPPID,
            authenticator: authenticator,
            loader: loader,
            requestGenerateUserSig: requestGenerateUserSig,
            requestLoadUserData: requestLoadUserData,
            requestPushInfo: requestPushInfo
        )
    }
}
