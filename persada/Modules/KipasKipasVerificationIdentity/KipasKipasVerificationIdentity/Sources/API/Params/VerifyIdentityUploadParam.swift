//
//  VerifyIdentityUploadParam.swift
//  KipasKipasVerificationIdentity
//
//  Created by DENAZMI on 07/06/24.
//

import Foundation

public struct VerifyIdentityUploadParam: Encodable {
    public var typeId: String
    public var countryId: String
    public var identityUrl: String
    public var selfieUrl: String
    public var email: String
    public var phone: String
    
    public init(
        typeId: String = "",
        countryId: String = "",
        identityUrl: String = "",
        selfieUrl: String = "",
        email: String = "",
        phone: String = ""
    ) {
        self.typeId = typeId
        self.countryId = countryId
        self.identityUrl = identityUrl
        self.selfieUrl = selfieUrl
        self.email = email
        self.phone = phone
    }
}
