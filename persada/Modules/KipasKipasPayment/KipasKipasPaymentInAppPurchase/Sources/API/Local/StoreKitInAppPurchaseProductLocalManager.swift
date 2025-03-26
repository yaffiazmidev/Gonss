//
//  StoreKitInAppPurchaseProductLocal.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/09/23.
//

import Foundation
import StoreKit

class StoreKitInAppPurchaseProductLocalManager {
    static let shared: StoreKitInAppPurchaseProductLocalManager = StoreKitInAppPurchaseProductLocalManager()
    
    private init() {}
    
    private var data: [SKProduct] = []
    
    func add(data with: SKProduct) {
        if !self.data.contains(where: { $0.productIdentifier == with.productIdentifier }) {
            data.append(with)
        }
    }
    
    func product(from iapProduct: InAppPurchaseProduct) throws -> SKProduct {
        if let product = self.data.first(where: { $0.productIdentifier == iapProduct.productIdentifier }) {
            return product
        }
        
        throw InAppPurchaseError.productNotFound
    }
}
