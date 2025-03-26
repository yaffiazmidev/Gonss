import Foundation

public struct LiveStreamCreation: Codable {
    public let roomId: String?
    public let status: Bool?
    public let streamingId: String?

    enum CodingKeys: String, CodingKey {
        case roomId
        case status
        case streamingId
    }
}
