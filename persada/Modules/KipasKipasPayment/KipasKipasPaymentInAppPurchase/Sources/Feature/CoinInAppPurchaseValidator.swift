//
//  CoinInAppPurchaseValidator.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

public struct CoinInAppPurchaseValidatorRequest: Equatable, Encodable {
    public let storeId: String
    public let transactionId: String
    
    public init(storeId: String, transactionId: String) {
        self.storeId = storeId
        self.transactionId = transactionId
    }
}

public protocol CoinInAppPurchaseValidator {
    typealias Result = Swift.Result<CoinInAppPurchaseValidateData, Error>
    
    func validate(request: CoinInAppPurchaseValidatorRequest, completion: @escaping (Result) -> Void)
}
