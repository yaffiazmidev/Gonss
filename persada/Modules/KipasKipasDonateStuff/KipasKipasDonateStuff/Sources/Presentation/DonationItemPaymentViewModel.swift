import Foundation

public struct DonationItemPaymentStatusViewModel {
    
    public enum PaymentStatus: String {
        case WAIT
        case PAID
        case EXPIRED
    }
    
    public let paymentStatus: PaymentStatus?
    public let expiredPaymentTime: Int
    
    public init(
        paymentStatus: PaymentStatus?,
        expiredPaymentTime: Int
    ) {
        self.paymentStatus = paymentStatus
        self.expiredPaymentTime = expiredPaymentTime
    }
    
    public var expiredPaymentTimeDesc: String {
        let date = Date(timeIntervalSince1970: TimeInterval(expiredPaymentTime / 1_000))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
        dateFormatter.locale = Locale(identifier: "id_ID")
        return dateFormatter.string(from: date)
    }
}

public struct DonationItemPaymentInitiatorViewModel {
    public let initiatorId: String
    public let initiatorName: String
    public let initiatorPhoto: String
    public let donationPhoto: String
    public let donationTitle: String
    
    public init(
        initiatorId: String,
        initiatorName: String,
        initiatorPhoto: String,
        donationPhoto: String,
        donationTitle: String
    ) {
        self.initiatorId = initiatorId
        self.initiatorName = initiatorName
        self.initiatorPhoto = initiatorPhoto
        self.donationPhoto = donationPhoto
        self.donationTitle = donationTitle
    }
}

public struct DonationItemPaymentProductViewModel {
    public let productId: String
    public let productName: String
    public let productPhoto: String
    public let productPrice: Double
    public let productQty: Int
    
    public init(
        productId: String,
        productName: String,
        productPhoto: String,
        productPrice: Double,
        productQty: Int
    ) {
        self.productId = productId
        self.productName = productName
        self.productPhoto = productPhoto
        self.productPrice = productPrice
        self.productQty = productQty
    }
}

public struct DonationItemPaymentTransactionViewModel {
    public let subtotal: Double
    public let shippingFee: Double
    public let adminFee: Double
    
    public init(
        subtotal: Double,
        shippingFee: Double,
        adminFee: Double
    ) {
        self.subtotal = subtotal
        self.shippingFee = shippingFee
        self.adminFee = adminFee
    }
}

public struct DonationItemPaymentMethodViewModel {
    
    public enum PaymentType: String {
        case ewallet = "e_wallet"
        case transfer
    }
    
    public let transactionNumber: String?
    public let transactionDate: Int
    public let bankName: String?
    public let paymentType: PaymentType?
    public let hasNoPaymentMethod: Bool
    
    public init(
        transactionNumber: String?,
        transactionDate: Int,
        bankName: String?,
        paymentType: PaymentType?,
        hasNoPaymentMethod: Bool
    ) {
        self.transactionNumber = transactionNumber
        self.transactionDate = transactionDate
        self.bankName = bankName
        self.paymentType = paymentType
        self.hasNoPaymentMethod = hasNoPaymentMethod
    }
    
    public var bankNameDesc: String {
        let defaultText = "Belum memilih metode pembayaran"
        return hasNoPaymentMethod && paymentType == .transfer ? defaultText : (bankName?.uppercased() ?? defaultText)
    }
    
    public var transactionNumberDesc: String {
        let defaultText = "Belum memilih metode pembayaran"
        return hasNoPaymentMethod && paymentType == .transfer ? defaultText : (transactionNumber ?? "N/A")
    }
    
    public var transactionDateDesc: String {
        let date = Date(timeIntervalSince1970: TimeInterval(transactionDate / 1_000))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy, h:mm a"
        dateFormatter.locale = Locale(identifier: "id_ID")
        return dateFormatter.string(from: date)
    }
}

public struct DonationItemPaymentViewModel {
    public let paymentURL: String
    public let status: DonationItemPaymentStatusViewModel
    public let initiator: DonationItemPaymentInitiatorViewModel
    public let product: DonationItemPaymentProductViewModel
    public let transaction: DonationItemPaymentTransactionViewModel
    public let method: DonationItemPaymentMethodViewModel
    
    public init(
        paymentURL: String,
        status: DonationItemPaymentStatusViewModel,
        initiator: DonationItemPaymentInitiatorViewModel,
        product: DonationItemPaymentProductViewModel,
        transaction: DonationItemPaymentTransactionViewModel,
        method: DonationItemPaymentMethodViewModel
    ) {
        self.paymentURL = paymentURL
        self.status = status
        self.initiator = initiator
        self.product = product
        self.transaction = transaction
        self.method = method
    }
}
