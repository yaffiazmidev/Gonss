import Foundation

public struct DonationItemListViewModel {
    public let items: [DonationItemViewModel]
    
    public init(items: [DonationItemViewModel]) {
        self.items = items
    }
}

public struct DonationItemViewModel: Hashable {
    public let detailId: String
    public let donationId: String
    public let itemId: String
    public let itemName: String
    public let itemImage: String
    public let itemPrice: Double
    public let itemTargetAmount: Int
    public let itemCollectedAmount: Int
    
    public init(
        detailId: String,
        donationId: String,
        itemId: String,
        itemName: String,
        itemImage: String,
        itemPrice: Double,
        itemTargetAmount: Int,
        itemCollectedAmount: Int
    ) {
        self.detailId = detailId
        self.donationId = donationId
        self.itemId = itemId
        self.itemName = itemName
        self.itemImage = itemImage
        self.itemPrice = itemPrice
        self.itemTargetAmount = itemTargetAmount
        self.itemCollectedAmount = itemCollectedAmount
    }
    
    public var collectionProgress: Float {
        Float(itemCollectedAmount) / Float(itemTargetAmount)
    }
    
    public var collectionCompleted: Bool {
        return collectionProgress >= 1.0
    }
    
    public var itemPriceDesc: String {
        return itemPrice.inRupiah()
    }
    
    public var itemAmountDesc: String {
        let collectedAmount = String(itemCollectedAmount)
        let targetAmount = String(itemTargetAmount)
        return collectedAmount + " / " + targetAmount
    }
    
    public var itemAmountHighlightedRange: NSRange? {
        /// In text for example "10 / 100",
        /// it will select the text before the "/" sign.
        let pattern = "([^/]+)"
        
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: []
        ) else {
            return nil
        }
        
        guard let match = regex.firstMatch(
            in: itemAmountDesc,
            options: [],
            range: NSRange(
                location: 0,
                length: itemAmountDesc.count
            )
        ) else {
            return nil
        }
        
        return match.range
    }
}


#warning("[PE-14005] move this")
public extension String {
    func asURL() -> URL? {
        guard let url = URL(string: self) else {
            return nil
        }
        return url
    }
}

public extension Double {
    func multiply(by value: Int) -> Double {
        return self * Double(value)
    }
    
    func inRupiah() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: NSNumber(value: self)) ?? "Rp0"
    }
}
