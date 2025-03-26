import Foundation

public struct RootData<Response: Codable>: Codable {
    public let code, message: String
    public let data: Response
    
    public init(code: String, message: String, data: Response) {
        self.code = code
        self.message = message
        self.data = data
    }
}

public typealias DonationItemData = RootData<[DonationItem]>

public struct DonationItem: Codable {
    public let id, postDonationId, productId: String?
    public let productName, productImage: String?
    public let itemPrice: Double?
    public let targetQty, totalItemCollected: Int?
    public let totalAmountItemCollected: Double?
    
    init(
        id: String?,
        postDonationId: String?,
        productId: String?,
        productName: String?,
        productImage: String?,
        itemPrice: Double?,
        targetQty: Int?,
        totalItemCollected: Int?,
        totalAmountItemCollected: Double?
    ) {
        self.id = id
        self.postDonationId = postDonationId
        self.productId = productId
        self.productName = productName
        self.productImage = productImage
        self.itemPrice = itemPrice
        self.targetQty = targetQty
        self.totalItemCollected = totalItemCollected
        self.totalAmountItemCollected = totalAmountItemCollected
    }
}

public extension DonationItem {
    static func mock(index: Int) -> DonationItem {        
        return .init(
            id: UUID().uuidString,
            postDonationId: UUID().uuidString,
            productId: UUID().uuidString,
            productName: "Product " + UUID().uuidString.prefix(8),
            productImage: images[safe: index],
            itemPrice: Double.random(in: 9999...1_000_000),
            targetQty: 100,
            totalItemCollected: Int.random(in: 0...100),
            totalAmountItemCollected: 1000.0
        )
    }
    
    #warning("[PE-14007] delete later")
    private static var images: [String] {
        return (0...50).compactMap { index in
            return "https://api.dicebear.com/8.x/initials/jpg?seed=\(index)"
        }
    }
}

#warning("[PE-14007] delete later")
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
