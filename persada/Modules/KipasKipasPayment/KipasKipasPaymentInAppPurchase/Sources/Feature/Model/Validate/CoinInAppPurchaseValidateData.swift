//
//  CoinInAppPurchaseValidateData.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

public struct CoinInAppPurchaseValidateData: Hashable {
    
    public let orderCoin: CoinInAppPurchaseValidateOrder
    public let notificationId: String
    
    internal init(orderCoin: CoinInAppPurchaseValidateOrder, notificationId: String) {
        self.orderCoin = orderCoin
        self.notificationId = notificationId
    }
}
