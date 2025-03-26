import Foundation

public struct LiveGift: Codable {
    public let id: String?
    public let giftURL: String?
    public let lottieURL: String?
    public let price: Int?
    public let title: String?

    enum CodingKeys: String, CodingKey {
        case id
        case giftURL = "giftUrl"
        case lottieURL = "lottieUrl"
        case price, title
    }
}
