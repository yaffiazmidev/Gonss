import Foundation

public struct RegisterRequestOTPViewModel {
    public let countdownInterval: Int
    
    public init(countdownInterval: Int) {
        self.countdownInterval = countdownInterval
    }
}
