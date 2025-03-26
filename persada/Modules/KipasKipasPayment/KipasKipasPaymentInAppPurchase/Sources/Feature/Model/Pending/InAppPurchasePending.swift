//
//  InAppPurchasePending.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/10/23.
//

import Foundation

public struct InAppPurchasePending: Codable {
    var transactionId: String
    var type: InAppPurchasePendingType
    
    public init(transactionId: String, type: InAppPurchasePendingType) {
        self.transactionId = transactionId
        self.type = type
    }
}
