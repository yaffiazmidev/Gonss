//
//  CoinInAppPurchaseValidateOrder.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

public struct CoinInAppPurchaseValidateOrder: Hashable {
    
    public let id: String
    public let createAt: String
    public let storeOrderId: String
    public let amount: Double
    public let status: String?
    public let customer: CoinInAppPurchaseValidateCustomer
    public let detail: CoinInAppPurchaseValidateOrderDetail
    public let noInvoice: String
    public let invoiceFileUrl: String?
    public let store: CoinInAppPurchaseValidateStore
    public let payment: String?
    
    
    internal init(id: String, createAt: String, storeOrderId: String, amount: Double, status: String?, customer: CoinInAppPurchaseValidateCustomer, detail: CoinInAppPurchaseValidateOrderDetail, noInvoice: String, invoiceFileUrl: String?, store: CoinInAppPurchaseValidateStore, payment: String?) {
        self.id = id
        self.createAt = createAt
        self.storeOrderId = storeOrderId
        self.amount = amount
        self.status = status
        self.customer = customer
        self.detail = detail
        self.noInvoice = noInvoice
        self.invoiceFileUrl = invoiceFileUrl
        self.store = store
        self.payment = payment
    }
}
