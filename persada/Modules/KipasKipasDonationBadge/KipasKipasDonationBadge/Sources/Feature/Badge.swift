import Foundation

public struct Badge: Codable {
    public let id, name: String?
    public let level: Int?
    public let isShowBadge, isMyBadge: Bool?
    public let min, max, diffNominalBadge: Int?
    public let url: String?
}
