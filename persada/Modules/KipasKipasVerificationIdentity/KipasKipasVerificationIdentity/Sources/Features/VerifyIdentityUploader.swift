//
//  VerifyIdentityUploader.swift
//  KipasKipasVerificationIdentity
//
//  Created by DENAZMI on 07/06/24.
//

import Foundation

public protocol VerifyIdentityUploader {
    typealias Result = Swift.Result<VerifyIdentityDefaultResponse, Error>
    
    func upload(_ request: VerifyIdentityUploadParam, completion: @escaping (Result) -> Void)
}
