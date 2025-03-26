import Foundation

public typealias RegisterRequestOTPData = RootData<RegisterRequestOTPResponse>

/**
 The `too many request` error have the same data model
 */
public typealias RegisterTooManyOTPRequestError = RegisterRequestOTPData

public struct RegisterRequestOTPResponse: Codable {
    public let expireInSecond, tryInSecond: Int?
    public let platform: String?
}
