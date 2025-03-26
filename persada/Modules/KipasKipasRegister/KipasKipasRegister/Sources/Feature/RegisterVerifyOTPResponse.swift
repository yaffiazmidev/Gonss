import Foundation

public typealias RegisterVerifyOTPData = RootData<RegisterVerifyOTPResponse>

public struct RegisterVerifyOTPResponse: Codable {
    public let isRegister: Bool?
    public let platform: String?
}
