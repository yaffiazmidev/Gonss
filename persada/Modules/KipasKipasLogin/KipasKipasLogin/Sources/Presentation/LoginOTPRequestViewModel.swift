import Foundation

public struct LoginOTPRequestViewModel {
    public let countdownInterval: TimeInterval
    
    public init(countdownInterval: TimeInterval) {
        self.countdownInterval = countdownInterval
    }
}
