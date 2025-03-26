//
//  RemoteCoinPurchaseValidateOrder.swift
//  KipasKipasDirectMessage
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/10/23.
//

import Foundation

///This data fetched from KipasKipas Rest
public struct RemoteCoinPurchaseValidateOrder: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case createAt
        case storeOrderId
        case amount
        case status
        case customer
        case orderDetailCoin
        case noInvoice
        case invoiceFileUrl
        case store
        case payment
    }
    
    public var id: String?
    public var createAt: String?
    public var storeOrderId: String?
    public var amount: Double?
    public var status: String?
    public var customer: RemoteCoinPurchaseValidateCustomer?
    public var orderDetailCoin: RemoteCoinPurchaseValidateOrderDetail?
    public var noInvoice: String?
    public var invoiceFileUrl: String?
    public var store: RemoteCoinPurchaseValidateStore?
    public var payment: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        createAt = try container.decodeIfPresent(String.self, forKey: .createAt)
        storeOrderId = try container.decodeIfPresent(String.self, forKey: .storeOrderId)
        amount = try container.decodeIfPresent(Double.self, forKey: .amount)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        customer = try container.decodeIfPresent(RemoteCoinPurchaseValidateCustomer.self, forKey: .customer)
        orderDetailCoin = try container.decodeIfPresent(RemoteCoinPurchaseValidateOrderDetail.self, forKey: .orderDetailCoin)
        noInvoice = try container.decodeIfPresent(String.self, forKey: .noInvoice)
        invoiceFileUrl = try container.decodeIfPresent(String.self, forKey: .invoiceFileUrl)
        store = try container.decodeIfPresent(RemoteCoinPurchaseValidateStore.self, forKey: .store)
        payment = try container.decodeIfPresent(String.self, forKey: .payment)
    }
}
