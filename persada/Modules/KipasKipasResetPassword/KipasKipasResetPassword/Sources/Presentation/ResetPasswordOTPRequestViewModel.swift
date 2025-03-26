import Foundation

public struct ResetPasswordOTPRequestViewModel {
    public let countdownInterval: TimeInterval
    
    public init(countdownInterval: TimeInterval) {
        self.countdownInterval = countdownInterval
    }
}
