import Foundation

public struct LiveStreamValidation: Codable {
    public let roomID: String?
    public let status: Bool?
    public let streamingID: String?

    enum CodingKeys: String, CodingKey {
        case roomID = "roomId"
        case status
        case streamingID = "streamingId"
    }
}
