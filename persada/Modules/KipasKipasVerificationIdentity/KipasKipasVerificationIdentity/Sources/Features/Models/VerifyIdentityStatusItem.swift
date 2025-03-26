//
//  VerifyIdentityStatusItem.swift
//  KipasKipasVerificationIdentity
//
//  Created by DENAZMI on 09/06/24.
//

import Foundation

public enum VerifyIdentityStatusType: String, Equatable {
    case unverified
    case uploaded
    case checking
    case validating
    case waiting_verification
    case verified
    case rejected
    case revision
}

public struct VerifyIdentityStatusItem {
    public let verifId: String
    public let accountId: String
    public let submitAt: Int
    public let submitCount: Int
    public let type: String?
    public let country: String
    public let accountName: String?
    public let birthDate: String?
    public let vendorVerificationStatus: String
    public let adminVerificationStatus: String
    public let identityUrl: String
    public let selfieUrl: String
    public let vendorUniqueId: String
    public let username: String
    public let photo: String
    public let isVerified: Bool
    public let reason: String
    public let reasonCategory: String
    public let accountPhoto: String
    public var phone: String
    public var email: String
    public var isPhoneNumberRevision: Bool
    public var isEmailRevision: Bool
    
    public var verificationStatusType: VerifyIdentityStatusType {
        return VerifyIdentityStatusType(rawValue: adminVerificationStatus.lowercased()) ?? .unverified
    }
    
    public init(
        verifId: String,
        accountId: String,
        submitAt: Int,
        submitCount: Int,
        type: String,
        country: String,
        accountName: String,
        birthDate: String,
        vendorVerificationStatus: String,
        adminVerificationStatus: String,
        identityUrl: String,
        selfieUrl: String,
        vendorUniqueId: String,
        username: String,
        photo: String,
        isVerified: Bool,
        reason: String,
        reasonCategory: String,
        accountPhoto: String,
        phone: String,
        email: String,
        isPhoneNumberRevision: Bool,
        isEmailRevision: Bool
    ) {
        self.verifId = verifId
        self.accountId = accountId
        self.submitAt = submitAt
        self.submitCount = submitCount
        self.type = type
        self.country = country
        self.accountName = accountName
        self.birthDate = birthDate
        self.vendorVerificationStatus = vendorVerificationStatus
        self.adminVerificationStatus = adminVerificationStatus
        self.identityUrl = identityUrl
        self.selfieUrl = selfieUrl
        self.vendorUniqueId = vendorUniqueId
        self.username = username
        self.photo = photo
        self.isVerified = isVerified
        self.reason = reason
        self.reasonCategory = reasonCategory
        self.accountPhoto = accountPhoto
        self.phone = phone
        self.email = email
        self.isPhoneNumberRevision = isPhoneNumberRevision
        self.isEmailRevision = isEmailRevision
    }
}
