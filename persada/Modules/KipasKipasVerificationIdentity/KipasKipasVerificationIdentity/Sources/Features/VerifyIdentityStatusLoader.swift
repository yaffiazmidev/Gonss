//
//  VerifyIdentityStatusLoader.swift
//  KipasKipasVerificationIdentity
//
//  Created by DENAZMI on 09/06/24.
//

import Foundation

public protocol VerifyIdentityStatusLoader {
    typealias Result = Swift.Result<VerifyIdentityStatusItem, Error>
    
    func load(completion: @escaping (Result) -> Void)
}
