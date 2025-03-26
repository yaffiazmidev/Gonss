import Foundation

// MARK: - DonationTransactionDetailOrderItem
public struct DonationTransactionDetailOrderItem: Hashable {
    
    public let id, noInvoice: String
    public let orderDetail: DonationTransactionDetailOrderDetailItem
    public let amount: Int
    public let payment: DonationTransactionDetailOrderPaymentItem
    public let orderShipment: DonationTransactionDetailOrderShipmentItem
    public let customer: DonationTransactionDetailOrderCustomerItem
    public let status, type: String
    public let reasonRejected: String?
    public let invoiceFileURL: String
    public let isOrderComplaint: Bool
    public let reviewStatus: String
    
    public init(id: String, noInvoice: String, orderDetail: DonationTransactionDetailOrderDetailItem, amount: Int, payment: DonationTransactionDetailOrderPaymentItem, orderShipment: DonationTransactionDetailOrderShipmentItem, customer: DonationTransactionDetailOrderCustomerItem, status: String, type: String, reasonRejected: String?, invoiceFileURL: String, isOrderComplaint: Bool, reviewStatus: String) {
        self.id = id
        self.noInvoice = noInvoice
        self.orderDetail = orderDetail
        self.amount = amount
        self.payment = payment
        self.orderShipment = orderShipment
        self.customer = customer
        self.status = status
        self.type = type
        self.reasonRejected = reasonRejected
        self.invoiceFileURL = invoiceFileURL
        self.isOrderComplaint = isOrderComplaint
        self.reviewStatus = reviewStatus
    }
}

// MARK: - Customer
public struct DonationTransactionDetailOrderCustomerItem: Hashable {
    
    public let id, username, name, bio: String
    public let photo, birthDate: String?
    public let gender: String
    public let isFollow, isSeleb: Bool
    public let mobile, email, accountType: String
    public let isVerified: Bool
    public let note: String?
    public let isDisabled, isSeller: Bool
    
    public init(id: String, username: String, name: String, bio: String, photo: String?, birthDate: String?, gender: String, isFollow: Bool, isSeleb: Bool, mobile: String, email: String, accountType: String, isVerified: Bool, note: String?, isDisabled: Bool, isSeller: Bool) {
        self.id = id
        self.username = username
        self.name = name
        self.bio = bio
        self.photo = photo
        self.birthDate = birthDate
        self.gender = gender
        self.isFollow = isFollow
        self.isSeleb = isSeleb
        self.mobile = mobile
        self.email = email
        self.accountType = accountType
        self.isVerified = isVerified
        self.note = note
        self.isDisabled = isDisabled
        self.isSeller = isSeller
    }
}

// MARK: - OrderDetail
public struct DonationTransactionDetailOrderDetailItem: Hashable {
    
    public let quantity: Int
    public let variant: String?
    public let measurement: DonationTransactionDetailOrderMeasurementItem
    public let feedId: String?
    public let productID, productName: String
    public let urlPaymentPage: String
    public let sellerAccountID, sellerName: String
    public let buyerName, buyerMobilePhone: String?
    public let productPrice: Int
    public let urlProductPhoto: String
    public let createAt, expireTimePayment: Int
    public let noInvoice, shipmentName, shipmentService, shipmentDuration: String?
    public let shipmentCost, shipmentActualCost, totalAmount, paymentName: String?
    public let paymentNumber, paymentType: String?
    public let productDescription, productCategoryID, productCategoryName: String
    public let initiatorId, initiatorName, postDonationId, urlInitiatorPhoto: String?
    public let donationTitle, urlDonationPhoto: String?
    public let productType: String
    public let commission, modal: Int
    public let resellerAccountID, productOriginalID: String
    public let urlSellerPhoto: String
    public let sellerUserName: String
    public let isSellerVerified: Bool
    
    public init(quantity: Int, variant: String?, measurement: DonationTransactionDetailOrderMeasurementItem, feedId: String?, productID: String, productName: String, urlPaymentPage: String, sellerAccountID: String, sellerName: String, buyerName: String?, buyerMobilePhone: String?, productPrice: Int, urlProductPhoto: String, createAt: Int, expireTimePayment: Int, noInvoice: String?, shipmentName: String?, shipmentService: String?, shipmentDuration: String?, shipmentCost: String?, shipmentActualCost: String?, totalAmount: String?, paymentName: String?, paymentNumber: String?, paymentType: String?, productDescription: String, productCategoryID: String, productCategoryName: String, initiatorId: String?, initiatorName: String?, postDonationId: String?, urlInitiatorPhoto: String?, donationTitle: String?, urlDonationPhoto: String?, productType: String, commission: Int, modal: Int, resellerAccountID: String, productOriginalID: String, urlSellerPhoto: String, sellerUserName: String, isSellerVerified: Bool) {
        self.quantity = quantity
        self.variant = variant
        self.measurement = measurement
        self.feedId = feedId
        self.productID = productID
        self.productName = productName
        self.urlPaymentPage = urlPaymentPage
        self.sellerAccountID = sellerAccountID
        self.sellerName = sellerName
        self.buyerName = buyerName
        self.buyerMobilePhone = buyerMobilePhone
        self.productPrice = productPrice
        self.urlProductPhoto = urlProductPhoto
        self.createAt = createAt
        self.expireTimePayment = expireTimePayment
        self.noInvoice = noInvoice
        self.shipmentName = shipmentName
        self.shipmentService = shipmentService
        self.shipmentDuration = shipmentDuration
        self.shipmentCost = shipmentCost
        self.shipmentActualCost = shipmentActualCost
        self.totalAmount = totalAmount
        self.paymentName = paymentName
        self.paymentNumber = paymentNumber
        self.paymentType = paymentType
        self.productDescription = productDescription
        self.productCategoryID = productCategoryID
        self.productCategoryName = productCategoryName
        self.initiatorId = initiatorId
        self.initiatorName = initiatorName
        self.postDonationId = postDonationId
        self.urlInitiatorPhoto = urlInitiatorPhoto
        self.donationTitle = donationTitle
        self.urlDonationPhoto = urlDonationPhoto
        self.productType = productType
        self.commission = commission
        self.modal = modal
        self.resellerAccountID = resellerAccountID
        self.productOriginalID = productOriginalID
        self.urlSellerPhoto = urlSellerPhoto
        self.sellerUserName = sellerUserName
        self.isSellerVerified = isSellerVerified
    }
}

// MARK: - Measurement
public struct DonationTransactionDetailOrderMeasurementItem: Hashable {
    
    public let weight, length, height, width: Double
    
    public init(weight: Double, length: Double, height: Double, width: Double) {
        self.weight = weight
        self.length = length
        self.height = height
        self.width = width
    }
}

// MARK: - OrderShipment
public struct DonationTransactionDetailOrderShipmentItem: Hashable {
    public let status: String
    public let consignee: String?
    public let notes, courier, duration, shipmentEstimation: String
    public let shippedAt: Int?
    public let cost: Int
    public let service, awbNumber, bookingNumber: String
    public let isWeightAdjustment: Bool?
    public let actualCost: Int?
    public let shippingLabelFileURL: String
    public let differentCost: Int?
    public let destinationID: String?
    public let destinationAddressID, destinationLabel, destinationReceiverName, destinationSenderName: String
    public let destinationPhoneNumber, destinationProvince, destinationProvinceID, destinationCity: String
    public let destinationCityID, destinationPostalCode, destinationSubDistrict, destinationSubDistrictID: String
    public let destinationLatitude, destinationLongitude: String
    public let destinationIsDefault, destinationIsDelivery: Bool
    public let destinationDetail: String
    public let originID: String?
    public let originAddressID, originLabel, originReceiverName, originSenderName: String
    public let originPhoneNumber, originProvince, originProvinceID, originCity: String
    public let originCityID, originPostalCode, originSubDistrict, originSubDistrictID: String
    public let originLatitude, originLongitude: String
    public let originIsDefault, originIsDelivery: Bool
    public let originDetail: String
    
    public init(status: String, consignee: String?, notes: String, courier: String, duration: String, shipmentEstimation: String, shippedAt: Int?, cost: Int, service: String, awbNumber: String, bookingNumber: String, isWeightAdjustment: Bool?, actualCost: Int?, shippingLabelFileURL: String, differentCost: Int?, destinationID: String?, destinationAddressID: String, destinationLabel: String, destinationReceiverName: String, destinationSenderName: String, destinationPhoneNumber: String, destinationProvince: String, destinationProvinceID: String, destinationCity: String, destinationCityID: String, destinationPostalCode: String, destinationSubDistrict: String, destinationSubDistrictID: String, destinationLatitude: String, destinationLongitude: String, destinationIsDefault: Bool, destinationIsDelivery: Bool, destinationDetail: String, originID: String?, originAddressID: String, originLabel: String, originReceiverName: String, originSenderName: String, originPhoneNumber: String, originProvince: String, originProvinceID: String, originCity: String, originCityID: String, originPostalCode: String, originSubDistrict: String, originSubDistrictID: String, originLatitude: String, originLongitude: String, originIsDefault: Bool, originIsDelivery: Bool, originDetail: String) {
        self.status = status
        self.consignee = consignee
        self.notes = notes
        self.courier = courier
        self.duration = duration
        self.shipmentEstimation = shipmentEstimation
        self.shippedAt = shippedAt
        self.cost = cost
        self.service = service
        self.awbNumber = awbNumber
        self.bookingNumber = bookingNumber
        self.isWeightAdjustment = isWeightAdjustment
        self.actualCost = actualCost
        self.shippingLabelFileURL = shippingLabelFileURL
        self.differentCost = differentCost
        self.destinationID = destinationID
        self.destinationAddressID = destinationAddressID
        self.destinationLabel = destinationLabel
        self.destinationReceiverName = destinationReceiverName
        self.destinationSenderName = destinationSenderName
        self.destinationPhoneNumber = destinationPhoneNumber
        self.destinationProvince = destinationProvince
        self.destinationProvinceID = destinationProvinceID
        self.destinationCity = destinationCity
        self.destinationCityID = destinationCityID
        self.destinationPostalCode = destinationPostalCode
        self.destinationSubDistrict = destinationSubDistrict
        self.destinationSubDistrictID = destinationSubDistrictID
        self.destinationLatitude = destinationLatitude
        self.destinationLongitude = destinationLongitude
        self.destinationIsDefault = destinationIsDefault
        self.destinationIsDelivery = destinationIsDelivery
        self.destinationDetail = destinationDetail
        self.originID = originID
        self.originAddressID = originAddressID
        self.originLabel = originLabel
        self.originReceiverName = originReceiverName
        self.originSenderName = originSenderName
        self.originPhoneNumber = originPhoneNumber
        self.originProvince = originProvince
        self.originProvinceID = originProvinceID
        self.originCity = originCity
        self.originCityID = originCityID
        self.originPostalCode = originPostalCode
        self.originSubDistrict = originSubDistrict
        self.originSubDistrictID = originSubDistrictID
        self.originLatitude = originLatitude
        self.originLongitude = originLongitude
        self.originIsDefault = originIsDefault
        self.originIsDelivery = originIsDelivery
        self.originDetail = originDetail
    }
}

// MARK: - Payment
public struct DonationTransactionDetailOrderPaymentItem: Hashable {
    public let amount: Int
    public let status: String
    public let paymentAccount: DonationTransactionDetailOrderPaymentAccountItem
    public let type: String
    public let bank: DonationTransactionDetailBankItem
    
    public init(amount: Int, status: String, paymentAccount: DonationTransactionDetailOrderPaymentAccountItem, type: String, bank: DonationTransactionDetailBankItem) {
        self.amount = amount
        self.status = status
        self.paymentAccount = paymentAccount
        self.type = type
        self.bank = bank
    }
}

// MARK: - PaymentAccount
public struct DonationTransactionDetailOrderPaymentAccountItem: Hashable {
    public let name, number: String
    public let billCode: String?
    
    public init(name: String, number: String, billCode: String?) {
        self.name = name
        self.number = number
        self.billCode = billCode
    }
}

public enum DonationTransactionDetailBankItem: String {
    case bca = "bca"
    case mandiri = "mandiri"
    case permata = "permata"
    case bni = "bni"
    case bri = "bri"
    case undifined
}
