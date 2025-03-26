import Foundation

public struct RemoteDonationTransactionOrderRoot: Codable {
    public let code, message: String
    public let data: RemoteDonationTransactionOrderItem
}

// MARK: - RemoteDonationTransactionOrderItem
public struct RemoteDonationTransactionOrderItem: Codable {
    public let id, noInvoice: String?
    public let orderDetail: RemoteDonationTransactionOrderDetailItem?
    public let amount: Int?
    public let payment: RemoteDonationTransactionOrderPaymentItem?
    public let orderShipment: RemoteDonationTransactionOrderShipmentItem?
    public let customer: RemoteDonationTransactionOrderCustomerItem?
    public let status, type: String?
    public let reasonRejected: String?
    public let invoiceFileURL: String?
    public let isOrderComplaint: Bool?
    public let reviewStatus: String?
}

// MARK: - Customer
public struct RemoteDonationTransactionOrderCustomerItem: Codable {
    public let id, username, name, bio: String?
    public let photo, birthDate: String?
    public let gender: String?
    public let isFollow, isSeleb: Bool?
    public let mobile, email, accountType: String?
    public let isVerified: Bool?
    public let note: String?
    public let isDisabled, isSeller: Bool?
}

// MARK: - OrderDetail
public struct RemoteDonationTransactionOrderDetailItem: Codable {
    public let quantity: Int?
    public let variant: String?
    public let measurement: RemoteDonationTransactionOrderMeasurementItem?
    public let feedId: String?
    public let productID, productName: String?
    public let urlPaymentPage: String?
    public let sellerAccountID, sellerName: String?
    public let buyerName, buyerMobilePhone: String?
    public let productPrice: Int?
    public let urlProductPhoto: String?
    public let createAt, expireTimePayment: Int?
    public let noInvoice, shipmentName, shipmentService, shipmentDuration: String?
    public let shipmentCost, shipmentActualCost, totalAmount, paymentName: String?
    public let paymentNumber, paymentType: String?
    public let productDescription, productCategoryID, productCategoryName: String?
    public let initiatorId, initiatorName, postDonationId, urlInitiatorPhoto: String?
    public let donationTitle, urlDonationPhoto: String?
    public let productType: String?
    public let commission, modal: Int?
    public let resellerAccountID, productOriginalID: String?
    public let urlSellerPhoto: String?
    public let sellerUserName: String?
    public let isSellerVerified: Bool?
}

// MARK: - Measurement
public struct RemoteDonationTransactionOrderMeasurementItem: Codable {
    public let weight, length, height, width: Double?
}

// MARK: - OrderShipment
public struct RemoteDonationTransactionOrderShipmentItem: Codable {
    public let status: String?
    public let consignee: String?
    public let notes, courier, duration, shipmentEstimation: String?
    public let shippedAt: Int?
    public let cost: Int?
    public let service, awbNumber, bookingNumber: String?
    public let isWeightAdjustment: Bool?
    public let actualCost: Int?
    public let shippingLabelFileURL: String?
    public let differentCost: Int?
    public let destinationID: String?
    public let destinationAddressID, destinationLabel, destinationReceiverName, destinationSenderName: String?
    public let destinationPhoneNumber, destinationProvince, destinationProvinceID, destinationCity: String?
    public let destinationCityID, destinationPostalCode, destinationSubDistrict, destinationSubDistrictID: String?
    public let destinationLatitude, destinationLongitude: String?
    public let destinationIsDefault, destinationIsDelivery: Bool?
    public let destinationDetail: String?
    public let originID: String?
    public let originAddressID, originLabel, originReceiverName, originSenderName: String?
    public let originPhoneNumber, originProvince, originProvinceID, originCity: String?
    public let originCityID, originPostalCode, originSubDistrict, originSubDistrictID: String?
    public let originLatitude, originLongitude: String?
    public let originIsDefault, originIsDelivery: Bool?
    public let originDetail: String?
}

// MARK: - Payment
public struct RemoteDonationTransactionOrderPaymentItem: Codable {
    public let amount: Int?
    public let status: String?
    public let paymentAccount: RemoteDonationTransactionOrderPaymentAccountItem?
    public let type: String?
    public let bank: String?
}

// MARK: - PaymentAccount
public struct RemoteDonationTransactionOrderPaymentAccountItem: Codable {
    public let name, number: String?
    public let billCode: String?
}

public enum RemoteDonationTransactionBankItem: String {
    case bca = "bca"
    case mandiri = "mandiri"
    case permata = "permata"
    case bni = "bni"
    case bri = "bri"
    case undifined
}
