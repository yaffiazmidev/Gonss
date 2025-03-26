import Foundation

public typealias DonationItemPaymentData = RootData<DonationItemPayment>

public struct DonationItemPayment: Codable {
    public let id, noInvoice: String?
    public let orderDetail: OrderDetail?
    public let amount: Double?
    public let payment: Payment?
    public let orderShipment, status, type, reasonRejected: String?
    public let invoiceFileUrl: String?
    public let isOrderComplaint: Bool?
    public let reviewStatus: String?

    public enum CodingKeys: String, CodingKey {
        case id, noInvoice, orderDetail, amount, payment, orderShipment, status, type, reasonRejected
        case invoiceFileUrl, isOrderComplaint, reviewStatus
    }

    public init(
        id: String?,
        noInvoice: String?,
        orderDetail: OrderDetail?,
        amount: Double?,
        payment: Payment?,
        orderShipment: String?,
        status: String?,
        type: String?,
        reasonRejected: String?,
        invoiceFileUrl: String?,
        isOrderComplaint: Bool?,
        reviewStatus: String?
    ) {
        self.id = id
        self.noInvoice = noInvoice
        self.orderDetail = orderDetail
        self.amount = amount
        self.payment = payment
        self.orderShipment = orderShipment
        self.status = status
        self.type = type
        self.reasonRejected = reasonRejected
        self.invoiceFileUrl = invoiceFileUrl
        self.isOrderComplaint = isOrderComplaint
        self.reviewStatus = reviewStatus
    }
}

// MARK: - OrderDetail
public struct OrderDetail: Codable {
    public let quantity: Int?
    public let feedId, productId, productName: String?
    public let urlPaymentPage: String?
    public let productPrice: Double?
    public let urlProductPhoto: String?
    public let createAt, expireTimePayment, shipmentCost, shipmentActualCost: Int?
    public let initiatorId, initiatorName, postDonationId: String?
    public let urlInitiatorPhoto: String?
    public let donationTitle: String?
    public let urlDonationPhoto: String?

    public enum CodingKeys: String, CodingKey {
        case feedId
        case productId
        case quantity
        case productName, urlPaymentPage
        case productPrice, urlProductPhoto, createAt, expireTimePayment, shipmentCost, shipmentActualCost
        case initiatorId
        case initiatorName
        case postDonationId
        case urlInitiatorPhoto, donationTitle, urlDonationPhoto
    }

    public init(
        feedId: String?,
        productId: String?,
        quantity: Int?,
        productName: String?,
        urlPaymentPage: String?,
        productPrice: Double?,
        urlProductPhoto: String?,
        createAt: Int?,
        expireTimePayment: Int?,
        shipmentCost: Int?,
        shipmentActualCost: Int?,
        initiatorId: String?,
        initiatorName: String?,
        postDonationId: String?,
        urlInitiatorPhoto: String?,
        donationTitle: String?,
        urlDonationPhoto: String?
    ) {
        self.feedId = feedId
        self.productId = productId
        self.quantity = quantity
        self.productName = productName
        self.urlPaymentPage = urlPaymentPage
        self.productPrice = productPrice
        self.urlProductPhoto = urlProductPhoto
        self.createAt = createAt
        self.expireTimePayment = expireTimePayment
        self.shipmentCost = shipmentCost
        self.shipmentActualCost = shipmentActualCost
        self.initiatorId = initiatorId
        self.initiatorName = initiatorName
        self.postDonationId = postDonationId
        self.urlInitiatorPhoto = urlInitiatorPhoto
        self.donationTitle = donationTitle
        self.urlDonationPhoto = urlDonationPhoto
    }
}

// MARK: - Payment
public struct Payment: Codable {
    public let amount: Double?
    public let status: String?
    public let paymentAccount: PaymentAccount?
    public let type, bank: String?

    public init(
        amount: Double?,
        status: String?,
        paymentAccount: PaymentAccount?,
        type: String?,
        bank: String?
    ) {
        self.amount = amount
        self.status = status
        self.paymentAccount = paymentAccount
        self.type = type
        self.bank = bank
    }
}

// MARK: - PaymentAccount
public struct PaymentAccount: Codable {
    public let name, number, billCode: String?

    public init(
        name: String?,
        number: String?,
        billCode: String?
    ) {
        self.name = name
        self.number = number
        self.billCode = billCode
    }
}

public extension DonationItemPayment {
    static var mock: DonationItemPayment {
        return .init(
            id: "402880cb8fbced15018fbd3740041a4c",
            noInvoice: "INV/KK/20240528/004",
            orderDetail: .init(
                feedId: "402880ab8f861e2a018f942d519263e8",
                productId: UUID().uuidString, 
                quantity: 4,
                productName: "Paket sembako 1 kardus",
                urlPaymentPage: "https://app.midtrans.com/snap/v4/redirection/2274c178-26a1-4a96-9425-377f9ad5e88c",
                productPrice: 145000.0,
                urlProductPhoto: "https://asset.kompas.com/crops/Ib6IMHhrSFHbNISXOoCoLchTQaM=/0x0:1373x915/750x500/data/photo/2022/09/26/63319bb758474.jpg",
                createAt: 1716866465807,
                expireTimePayment: 1716952865796,
                shipmentCost: 0,
                shipmentActualCost: 0,
                initiatorId: "3787",
                initiatorName: "Chelsea Gracia Manullang",
                postDonationId: "402880ab8f861e2a018f942d518663e1",
                urlInitiatorPhoto: "https://api.dicebear.com/8.x/initials/jpg?seed=CG",
                donationTitle: "PERJUANGAN GADIS KECIL KELAINAN TULANG LANGKA UNTUK MERAIH MASA DEPAN",
                urlDonationPhoto: "https://asset.kipaskipas.com/img/media/1716177573434.png"
            ),
            amount: 580000.0,
            payment: .init(
                amount:  580000.0,
                status: "WAIT",
                paymentAccount: .init(
                    name: "bca",
                    number: "1336185156570243",
                    billCode: ""
                ),
                type: "transfer",
                bank: "bca"
            ),
            orderShipment: "",
            status: "NEW",
            type: "donation",
            reasonRejected: "",
            invoiceFileUrl: "",
            isOrderComplaint: false,
            reviewStatus: "WAIT"
        )
    }
}
