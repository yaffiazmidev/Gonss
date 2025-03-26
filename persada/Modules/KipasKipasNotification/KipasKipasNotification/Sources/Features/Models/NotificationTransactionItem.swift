import Foundation
public struct NotificationTransactionContent {
    public let content: [NotificationTransactionItem]
    public var totalPages: Int?
}

// MARK: - Content
public struct NotificationTransactionItem: Equatable {
    public let id, orderType, status, paymentStatus, notifType: String
    public let shipmentStatus: String
    public let accountShopType: String
    public let accountDonationType: String
    public let account: NotificationSuggestionAccountItem
    public let orderID: String
    public let createAt: Int
    public let message: String
    public let urlProductPhoto: String
    public var isRead, isNotifWeightAdj, isProductBanned: Bool
    public let productID: String
    public let withdrawType: String
    public let withdrawl: NotificationWithdrawl
    public let currency: NotificationTransactionItemCurrency
    public let groupOrderId: String?
    
    public static func == (lhs: NotificationTransactionItem, rhs: NotificationTransactionItem) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct NotificationTransactionItemCurrency {
    public let orderId: String
    public let withdrawCurrencyId: String
    public let currencyType: String
    public let qty: Int
    public let price: Double
    public let totalWithdraw: Double
    public let bankAccount: String
    public let storeName: String
    public let bankAccountName: String
    public let bankName: String
    public let bankFee: Double
    public let modifyAt: String
    public let status: String
    public let noInvoice: String
}

public struct NotificationWithdrawl {
    public let id, status: String
    public let nominal, bankFee, total: Double
    public let bankAccount, referenceNo, bankAccountName, bankName: String
}
