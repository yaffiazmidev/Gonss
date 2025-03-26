import Foundation

public typealias ResetPasswordOTPData = RootData<ResetPasswordOTPResponse>

/**
 The `too many request` error have the same data model
 */
public typealias ResetPasswordTooManyOTPRequestError = ResetPasswordOTPData

public struct ResetPasswordOTPResponse: Codable {
    public let expireInSecond, tryInSecond: Int?
    public let platform: String?
}
