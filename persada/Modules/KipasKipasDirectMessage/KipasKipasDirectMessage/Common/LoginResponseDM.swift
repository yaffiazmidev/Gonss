//
//  LoginResponseDM.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 02/08/23.
//

import Foundation

#warning("[BEKA] Get rid of this")
public struct LoginResponseDM: Codable {

  enum CodingKeys: String, CodingKey {
    case code
    case userName
    case scope
    case userNo
    case role
    case appSource
    case accountId
    case userMobile
    case userEmail
    case expiresIn = "expires_in"
    case timelapse
    case tokenType = "token_type"
    case authorities
    case accessToken = "access_token"
    case jti
    case token
    case refreshToken = "refresh_token"
  }

    public var code: String?
    public var userName: String?
    public var scope: String?
    public var userNo: Int?
    public var role: String?
    public var appSource: String?
    public var accountId: String?
    public var userMobile: String?
    public var userEmail: String?
    public var expiresIn: Int?
    public var timelapse: Int?
    public var tokenType: String?
    public var authorities: [String]?
    public var accessToken: String?
    public var jti: String?
    public var token: String?
    public var refreshToken: String?



 public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    userName = try container.decodeIfPresent(String.self, forKey: .userName)
    scope = try container.decodeIfPresent(String.self, forKey: .scope)
    userNo = try container.decodeIfPresent(Int.self, forKey: .userNo)
    role = try container.decodeIfPresent(String.self, forKey: .role)
    appSource = try container.decodeIfPresent(String.self, forKey: .appSource)
    accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
    userMobile = try container.decodeIfPresent(String.self, forKey: .userMobile)
    userEmail = try container.decodeIfPresent(String.self, forKey: .userEmail)
    expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
    timelapse = try container.decodeIfPresent(Int.self, forKey: .timelapse)
    tokenType = try container.decodeIfPresent(String.self, forKey: .tokenType)
    authorities = try container.decodeIfPresent([String].self, forKey: .authorities)
    accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
    jti = try container.decodeIfPresent(String.self, forKey: .jti)
    token = try container.decodeIfPresent(String.self, forKey: .token)
    refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
  }

}
