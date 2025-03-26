//
//  CallLoaderAuthDecorator.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/24.
//

import Foundation
import KipasKipasNetworking

public class CallLoaderAuthDecorator: CallLoader {
    
    private let decoratee: CallLoader
    private let auth: CallAuthenticator
    
    public init(decoratee: CallLoader, auth: CallAuthenticator) {
        self.decoratee = decoratee
        self.auth = auth
    }
    
    public func call(with request: CallLoaderRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        decoratee.call(with: request) {  [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                if let error = failure as? KKNetworkError {
                    if case .responseFailure(let kKErrorNetworkResponse) = error,
                       kKErrorNetworkResponse.code == "-1201",
                       let authRequest = TUICallManager.selfInstance.authRequest {
                        self.auth.login(with: authRequest) { [weak self] authResult in
                            guard let self = self else { return }
                            
                            switch authResult {
                            case .success(_):
                                self.decoratee.call(with: request, completion: completion)
                            case .failure(_):
                                completion(.failure(failure))
                            }
                        }
                        return
                        
                    }
                    
                    completion(.failure(failure))
                }
            }
        }
    }
}
