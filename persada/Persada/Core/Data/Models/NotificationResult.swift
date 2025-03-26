//
//  NotificationResult.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct NotificationSocialResult: Codable {
    var code: String?
    var message: String?
    var data: NotificationData?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
    }
}

struct NotificationData: Codable {
    let content: [NotificationSocial]?
    let totalElements: Int?
    let last: Bool?
    let totalPages: Int?
    let first: Bool?
    let numberOfElements: Int?
    let size, number: Int?
    let empty: Bool?
}

struct NotificationSocial: Codable {
    let id, actionId, targetId, feed: String?
    let actionType, targetType, actionMessage: String?
    let createAt: Int?
    let actionAccount: Profile?
    var isRead: Bool?
    let size: Int?
	let thumbnailPhoto: String?
}

//------------Transaction
struct NotificationTransactionResult: Codable {
    var code: String?
    var message: String?
    var data: NotificationTransactionData?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
    }
}

struct NotificationTransactionData: Codable {
    let content: [NotificationTransaction]?
    let pageable: Pageable?
    let totalElements: Int?
    let last: Bool?
    let totalPages: Int?
    let first: Bool?
    let numberOfElements: Int?
    let sort: Sort?
    let size, number: Int?
    let empty: Bool?
}

// MARK: - Content
struct NotificationTransaction: Codable {
    let id, orderType, status, paymentStatus, notifType: String?
    let shipmentStatus: String?
    let accountShopType: String?
    let account: Profile?
    let orderID: String?
    let createAt: Int?
    let message: String?
    let urlProductPhoto: String?
    var isRead, isNotifWeightAdj, isProductBanned: Bool?
    let productID: String?
    let withdrawType: String?
    let withdrawl: Withdrawl?
    let currency: NotificationTransactionCurrency?
    let groupOrderId: String?

    enum CodingKeys: String, CodingKey {
        case id, orderType, status, paymentStatus, shipmentStatus, accountShopType, account, notifType
        case orderID = "orderId"
        case createAt, message, urlProductPhoto, isRead, isNotifWeightAdj, isProductBanned
        case productID = "productId"
        case withdrawType, withdrawl
        case currency
        case groupOrderId
    }
}

struct NotificationTransactionCurrency: Codable {
    let orderId: String?
    let withdrawCurrencyId: String?
    let currencyType: String?
    let qty: Int?
    let price: Double?
    let totalWithdraw: Double?
    let bankAccount: String?
    let storeName: String?
    let bankAccountName: String?
    let bankName: String?
    let bankFee: Double?
    let modifyAt: String?
    let status: String?
    let noInvoice: String?
}

struct Withdrawl: Codable {
    let id, status: String?
    let nominal, bankFee, total: Double?
    let bankAccount, referenceNo, bankAccountName, bankName: String?
}
