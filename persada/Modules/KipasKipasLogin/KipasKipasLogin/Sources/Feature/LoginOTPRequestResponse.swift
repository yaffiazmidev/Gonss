import Foundation

public typealias LoginOTPRequestData = RootData<LoginOTPRequestResponse>

/**
 The `too many request` error have the same data model
 */
public typealias LoginOTPTooManyRequestError = LoginOTPRequestData

public struct LoginOTPRequestResponse: Codable {
    public let expireInSecond, tryInSecond: Int?
    public let platform: String?
}
