import Foundation

public struct DonationItemCheckoutRequest: Encodable {
    public let donationItemId: String
    public let qty: Int
    
    public init(
        donationItemId: String,
        qty: Int
    ) {
        self.donationItemId = donationItemId
        self.qty = qty
    }
}
