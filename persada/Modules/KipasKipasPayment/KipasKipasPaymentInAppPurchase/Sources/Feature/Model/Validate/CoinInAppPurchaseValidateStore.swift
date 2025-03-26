//
//  CoinInAppPurchaseValidateStore.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

public struct CoinInAppPurchaseValidateStore: Hashable {
    public let id: String
    public let storeName: String
    
    internal init(id: String, storeName: String) {
        self.id = id
        self.storeName = storeName
    }
}
