//
//  TUICallAuthenticator.swift.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/24.
//

import Foundation
import TUICore
import KipasKipasNetworking
import KipasKipasShared

public class TUICallAuthenticator: CallAuthenticator {
    
    public init() {}
    
    public func login(with request: ICallLoginAuthenticatorRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let request = request as? TUICallLoginAuthenticatorRequest else {
            completion(.failure(KKNetworkError.invalidData))
            return
        }
        
        TUILogin.login(Int32(request.sdkAppId), userID: request.userId, userSig: request.userSig) {
            TUICallManager.selfInstance.authRequest = request
            TUICallManager.instance.setSelfInfo(nickname: request.fullName, avatar: request.pictureUrl) {} fail: { code, message in }
            completion(.success(()))
        } fail: { code, message in
            completion(.failure(TUICallManager.selfInstance.mapError(code: code, message: message)))
        }
    }
    
    public func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        TUILogin.logout {
            completion(.success(()))
        } fail: { code, message in
            if code == 6013 {
                completion(.success(()))
                return
            }
            completion(.failure(TUICallManager.selfInstance.mapError(code: code, message: message)))
        }
    }
}

extension MainQueueDispatchDecorator: CallAuthenticator where T == CallAuthenticator {
    public func login(with request: ICallLoginAuthenticatorRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        decoratee.login(with: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    public func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        decoratee.logout { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
}
