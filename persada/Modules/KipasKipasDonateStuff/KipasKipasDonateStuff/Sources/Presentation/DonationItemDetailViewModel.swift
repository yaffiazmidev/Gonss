import Foundation

// MARK: Image Section
public struct DonationItemDetailImage {
    public let imageURL: String
    
    public init(imageURL: String) {
        self.imageURL = imageURL
    }
}

// MARK: Info Section
public typealias DonationItemDetailInfo = DonationItemViewModel

// MARK: Stakeholder Section
public struct DonationItemDetailStakeholder {
    public let supplierName: String
    public let supplierImage: String
    public let initiatorName: String
    public let initiatorImage: String
    public let shippingAddress: String
    
    public init(
        supplierName: String,
        supplierImage: String,
        initiatorName: String,
        initiatorImage: String,
        shippingAddress: String
    ) {
        self.supplierName = supplierName
        self.supplierImage = supplierImage
        self.initiatorName = initiatorName
        self.initiatorImage = initiatorImage
        self.shippingAddress = shippingAddress
    }
}

// MARK: Description Section
public struct DonationItemDetailDescription {
    public let description: String
    
    public init(description: String) {
        self.description = description
    }
}

// MARK: Section Composer
public struct DonationItemDetailViewModel {
    public let id: String
    public let productImages: [DonationItemDetailImage]
    public let info: DonationItemDetailInfo
    public let stakeholder: DonationItemDetailStakeholder
    public let desc: DonationItemDetailDescription
    
    public init(
        id: String,
        productImages: [DonationItemDetailImage],
        info: DonationItemDetailInfo,
        stakeholder: DonationItemDetailStakeholder,
        desc: DonationItemDetailDescription
    ) {
        self.id = id
        self.productImages = productImages
        self.info = info
        self.stakeholder = stakeholder
        self.desc = desc
    }
}
