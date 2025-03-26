//
//  HistoryTransactionResponse.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

struct HistoryTransactionResponse: Codable {
    let histories: [History]
    
    enum CodingKeys: String, CodingKey {
        case histories = "history"
    }
    
    struct History: Codable {
        let orderId: String?
        let nominal: Int
        let activityType: String
        let createAt: Int
        let noInvoice: String?
        let historyType: String
        let bankFee: Int?
        let bankName: String?
        let bankAccountName: String?
        let bankAccountNumber: String?
    }
}

struct HistoryTransactionDetailOrderResponse: Codable {
    let noInvoice: String?
    let orderDetail: OrderDetail?
    let orderShipment: OrderShipment?
    let amount: Double?
}

struct HistoryTransactionDetailRefundResponse: Codable {
    let createAt: Int?
    let noInvoice: String?
    let urlProductPhoto: String?
    let productName: String?
    let quantity: Int?
    let productPrice: Double?
    let shipmentCostInitial: Double?
    let shipmentCostReturn: Double?
    let shipmentCostFinal: Double?
    let amount: Double?
}
