import Foundation

public typealias DonationItemDetailData = RootData<DonationItemDetail>

public struct DonationItemDetail: Codable {
    public let id: String?
    public let donationItemId, productId, productName: String?
    public let targetQty, totalItemCollected: Int?
    public let sellerName, initiatorName, sellerImage, initiatorImage: String?
    public let shippingAddress, description: String?
    public let itemPrice: Double?
    public let media: [DonationItemMedia]?
    
    init(
        id: String?,
        donationItemId: String?,
        productId: String?,
        productName: String?,
        targetQty: Int?,
        totalItemCollected: Int?,
        sellerName: String?,
        initiatorName: String?,
        sellerImage: String?,
        initiatorImage: String?,
        shippingAddress: String?,
        description: String?,
        itemPrice: Double?,
        media: [DonationItemMedia]?
    ) {
        self.id = id
        self.donationItemId = donationItemId
        self.productId = productId
        self.productName = productName
        self.targetQty = targetQty
        self.totalItemCollected = totalItemCollected
        self.sellerName = sellerName
        self.initiatorName = initiatorName
        self.sellerImage = sellerImage
        self.initiatorImage = initiatorImage
        self.shippingAddress = shippingAddress
        self.description = description
        self.itemPrice = itemPrice
        self.media = media
    }
}

public struct DonationItemMedia: Codable {
    public let id, type: String?
    public let url: String?

    public init(
        id: String?,
        type: String?,
        url: String?
    ) {
        self.id = id
        self.type = type
        self.url = url
    }
}

#warning("[PE-14005] delete later")
public extension DonationItemDetail {
    static var mock: DonationItemDetail {
        return .init(
            id: "222",
            donationItemId: "123",
            productId: "4",
            productName: "Lorem ipsum dolor sit amet, scrunctum ola slowa nesus.",
            targetQty: 500,
            totalItemCollected: 423,
            sellerName: "Superindo",
            initiatorName: "Yayasan Cahaya Mentari Pagi",
            sellerImage: "https://api.dicebear.com/8.x/initials/jpg?seed=SP",
            initiatorImage: "https://api.dicebear.com/8.x/initials/jpg?seed=IN",
            shippingAddress: "Jl Mangga Besar no VIII, Rt 001 / Rw 0001, Taman Sari, Taman Sari Jakarta Barat 115001",
            description: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ornare metus a neque cursus, non vulputate leo consectetur. Aenean placerat est vel ligula euismod, eget viverra dui consequat. Nunc quis arcu in orci dignissim iaculis. Maecenas laoreet nunc et volutpat blandit. Integer id lobortis sem. Integer faucibus fermentum iaculis. In accumsan augue massa, tincidunt molestie nisl scelerisque ac. Donec ultricies at ex a luctus.

In hac habitasse platea dictumst. Etiam tempor accumsan nisi, in mollis justo. Pellentesque eget nisi ullamcorper, convallis metus vel, elementum orci. Cras id vulputate dui. Nam vel elit maximus, varius massa sed, iaculis nunc. Aliquam quis sagittis felis. Mauris et mollis dui, eu eleifend massa. Nullam consectetur quam eu dui imperdiet aliquet. Duis diam orci, dignissim id imperdiet sed, fermentum vel tellus. Nam malesuada convallis leo a dignissim. Pellentesque fermentum posuere velit.

Phasellus fermentum iaculis nisi id fermentum. Suspendisse placerat consectetur ipsum, ut feugiat lacus sagittis sed. Proin ac ex mollis, fermentum turpis ultrices, porttitor diam. Etiam in mattis sapien, et eleifend tortor. Praesent sed hendrerit eros, id vulputate enim. In non eros neque. Morbi id molestie lectus. Vivamus feugiat sit amet orci id vulputate. Pellentesque dui velit, euismod sed aliquam in, convallis eu magna. Nunc ut ultricies augue, a dapibus nisi.

Ut porta faucibus maximus. Proin erat erat, viverra eget pretium vitae, luctus eu massa. Vivamus ac nisi id turpis ullamcorper mollis. Etiam tincidunt, ipsum nec aliquam iaculis, tortor metus dignissim dui, vel interdum turpis leo in diam. Sed mollis odio non sapien accumsan, vel aliquet nibh dignissim. Nulla bibendum, magna at tempor bibendum, eros lorem porta quam, non volutpat eros nisl vitae nunc. Nullam nec nulla vitae odio ultrices malesuada.

Cras condimentum dui ac venenatis vehicula. Cras porta mattis massa, eu venenatis tellus facilisis sit amet. Proin vel molestie massa. Maecenas nunc velit, facilisis in facilisis nec, sollicitudin vel dui. Maecenas venenatis feugiat lacus. Nulla ex tortor, congue a rutrum id, sollicitudin eget mi. Nullam lorem nisl, tincidunt eu odio quis, tincidunt laoreet eros. Suspendisse augue neque, finibus sodales iaculis quis, aliquet nec urna. Proin blandit convallis ligula, at tincidunt neque rhoncus iaculis.

Phasellus fermentum iaculis nisi id fermentum. Suspendisse placerat consectetur ipsum, ut feugiat lacus sagittis sed. Proin ac ex mollis, fermentum turpis ultrices, porttitor diam. Etiam in mattis sapien, et eleifend tortor. Praesent sed hendrerit eros, id vulputate enim. In non eros neque. Morbi id molestie lectus. Vivamus feugiat sit amet orci id vulputate. Pellentesque dui velit, euismod sed aliquam in, convallis eu magna. Nunc ut ultricies augue, a dapibus nisi.
""",
            itemPrice:  145000.00,
            media: []
        )
    }
}
