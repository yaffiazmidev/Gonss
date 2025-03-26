import Foundation

public struct LiveStreamSummary: Codable {
    public let streamingID: String?
    public let totalAudience, totalLike, totalDuration, totalDiamond: Int?

    enum CodingKeys: String, CodingKey {
        case streamingID = "streamingId"
        case totalAudience, totalLike, totalDuration, totalDiamond
    }
}

