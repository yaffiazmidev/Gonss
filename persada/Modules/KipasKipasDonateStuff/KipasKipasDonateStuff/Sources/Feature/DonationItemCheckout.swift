import Foundation

public typealias DonationItemCheckoutData = RootData<DonationItemCheckout>

public struct DonationItemCheckout: Codable {
    public let orderId: String
    public let redirectUrl: String
    public let token: String
}
