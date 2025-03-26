import Foundation

public struct GiftBoxLotteryScheduleViewModel {
    public let interval: TimeInterval
    public let daysRemaining: Int
    
    public var isLessThanADay: Bool {
        return daysRemaining <= 0
    }
    
    public init(interval: TimeInterval, daysRemaining: Int) {
        self.interval = interval
        self.daysRemaining = daysRemaining
    }
}
