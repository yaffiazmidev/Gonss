//
//  RemoteCoinInAppPurchaseValidateOrder.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

struct RemoteCoinInAppPurchaseValidateOrder: Codable {
    
    let id: String?
    let createAt: String?
    let storeOrderId: String?
    let amount: Double?
    let status: String?
    let customer: RemoteCoinInAppPurchaseValidateCustomer?
    let orderDetailCoin: RemoteCoinInAppPurchaseValidateOrderDetail?
    let noInvoice: String?
    let invoiceFileUrl: String?
    let store: RemoteCoinInAppPurchaseValidateStore?
    let payment: String?
    
}
