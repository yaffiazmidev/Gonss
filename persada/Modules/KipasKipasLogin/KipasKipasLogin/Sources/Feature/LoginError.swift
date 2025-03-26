import Foundation

public enum LoginError: String {
    case authorizationFailed = "2222"
    case loginFreeze = "4001"
}

public enum LoginWithOTPError: String {
    case wrongOTP = "4041"
    case userFreeze = "2200"
    case credentialNotFound = "9000"
}
