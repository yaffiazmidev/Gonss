//
//  CoinInAppPurchaseValidateOrderDetail.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

public struct CoinInAppPurchaseValidateOrderDetail: Hashable {
    
    public let id: String
    public let coinId: String
    public let coinName: String
    public let coinPrice: Double
    public let coinAmount: Int
    public let storeProductId: String
    public let qty: Int
    public let storeEventTime: String
    public let totalAmount: Double
    
    internal init(id: String, coinId: String, coinName: String, coinPrice: Double, coinAmount: Int, storeProductId: String, qty: Int, storeEventTime: String, totalAmount: Double) {
        self.id = id
        self.coinId = coinId
        self.coinName = coinName
        self.coinPrice = coinPrice
        self.coinAmount = coinAmount
        self.storeProductId = storeProductId
        self.qty = qty
        self.storeEventTime = storeEventTime
        self.totalAmount = totalAmount
    }
}
