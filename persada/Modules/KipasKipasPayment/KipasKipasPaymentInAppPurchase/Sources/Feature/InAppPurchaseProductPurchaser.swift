//
//  InAppPurchaseProductPurchaser.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/09/23.
//

import Foundation

public struct InAppPurchaseProductPurchaserRequest {
    public let product: InAppPurchaseProduct
    public let applicationUsername: String
    
    public init(product: InAppPurchaseProduct, applicationUsername: String) {
        self.product = product
        self.applicationUsername = applicationUsername
    }
}

public protocol InAppPurchaseProductPurchaser {
    typealias Result = Swift.Result<InAppPurchasePaymentTransaction, Error>
    
    func purchase(request: InAppPurchaseProductPurchaserRequest, completion: @escaping (Result) -> Void)
}
