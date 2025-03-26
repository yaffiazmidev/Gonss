import Foundation
import KipasKipasNetworking

public typealias LiveDailyRank = Root<[DailyRank]>

public struct DailyRank: Codable {
    public let account: Account?
    public let totalLike, totalDuration: Int?

    public init(account: Account?, totalLike: Int?, totalDuration: Int?) {
        self.account = account
        self.totalLike = totalLike
        self.totalDuration = totalDuration
    }
}
