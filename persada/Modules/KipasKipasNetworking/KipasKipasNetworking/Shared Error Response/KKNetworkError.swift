//
//  KKNetworkError.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 02/11/22.
//

import Foundation

public enum KKNetworkError: Error {
    case connectivity
    case invalidData
    case invalidDataWith(description: KKErrorDescription?, data: Data)
    case responseFailure(KKErrorNetworkResponse)
    case tokenExpired
    case tokenNotFound
    case keychainNotFound
    case failedToLoadKeychain(Error)
    case failedToSaveKeychain(Error)
    case failed
    case notFound
    case emailAlreadyExists
    case usernameAlreadyExists
    case notVerifyReseller
    case timeOut
    case InvalidAccessKeyId
    case general(Error)
}

extension KKNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .connectivity:
            return NSLocalizedString("Network error.", comment: "Error Connectivity")
        case .invalidData:
            return NSLocalizedString("Invalid Data.", comment: "Invalid Data")
        case .invalidDataWith:
            return NSLocalizedString("Invalid Data.", comment: "Invalid Data")
        case .responseFailure(let response):
            return NSLocalizedString("Request Failure. \(response.message)", comment: "Response Failure")
        case .tokenExpired:
            return NSLocalizedString("Token has expired.", comment: "Token Expired")
        case .tokenNotFound:
            return NSLocalizedString("Token not found.", comment: "Token not found")
        case .keychainNotFound:
            return NSLocalizedString("Keychain not found.", comment: "Keychain not found")
        case .failedToLoadKeychain(_):
            return NSLocalizedString("Failed to load keychain.", comment: "Failed to load keychain")
        case .failedToSaveKeychain(_):
            return NSLocalizedString("Failed to save keychain.", comment: "Failed to save keychain")
        case .failed:
            return NSLocalizedString("Failed.", comment: "Failed")
        case .notFound:
            return NSLocalizedString("Not Found.", comment: "Not Found")
        case .emailAlreadyExists:
            return NSLocalizedString("Email Already Exist.", comment: "Email Already Exist")
        case .usernameAlreadyExists:
            return NSLocalizedString("Username Already Exist.", comment: "Username Already Exist")
        case .notVerifyReseller:
            return NSLocalizedString("Reseller not Verified.", comment: "Reseller not Verified")
        case .timeOut:
            return NSLocalizedString("Request Time Out.", comment: "Request Time Out")
        case .InvalidAccessKeyId:
            return NSLocalizedString("OSS Token InvalidAccessKeyId.", comment: "InvalidAccessKeyId")
        case .general(let error):
            return NSLocalizedString(error.localizedDescription, comment: "General error")
        }
    }
}
