//
//  CallAuthenticator.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/24.
//

import Foundation

public protocol CallAuthenticator {
    func login(with request: ICallLoginAuthenticatorRequest, completion: @escaping (Swift.Result<Void, Error>) -> Void)
    
    func logout(completion: @escaping (Swift.Result<Void, Error>) -> Void)
}
