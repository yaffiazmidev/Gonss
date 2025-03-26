import Foundation

 public struct DonationTransactionDetailGroupItem: Equatable, Hashable {
    public let donations: [DonationGroupItem]
    public let totalAmount: Int
    
    public init(donations: [DonationGroupItem], totalAmount: Int) {
        self.donations = donations
        self.totalAmount = totalAmount
    }
}

public struct DonationGroupItem: Equatable, Hashable {
    public let postDonationID, title: String
    public let urlPhoto: String
    public let amount: Int
    
    public init(postDonationID: String, title: String, urlPhoto: String, amount: Int) {
        self.postDonationID = postDonationID
        self.title = title
        self.urlPhoto = urlPhoto
        self.amount = amount
    }
}
