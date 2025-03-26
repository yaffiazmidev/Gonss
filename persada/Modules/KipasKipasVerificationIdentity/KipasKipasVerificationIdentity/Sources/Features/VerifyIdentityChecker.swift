//
//  VerifyIdentityChecker.swift
//  KipasKipasVerificationIdentity
//
//  Created by DENAZMI on 05/06/24.
//

import Foundation

public protocol VerifyIdentityChecker {
    typealias Result = Swift.Result<VerifyIdentityCheckItem, Error>
    
    func check(completion: @escaping (Result) -> Void)
}
