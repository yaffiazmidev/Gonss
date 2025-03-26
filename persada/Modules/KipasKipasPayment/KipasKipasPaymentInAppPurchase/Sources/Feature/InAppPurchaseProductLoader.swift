//
//  InAppPurchaseProductLoader.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/09/23.
//

import Foundation

public struct InAppPurchaseProductLoaderRequest: Equatable {
    public var identifiers: [String]
    
    public init(identifiers: [String]) {
        self.identifiers = identifiers
    }
    
    public init(){
        self.identifiers = []
    }
}

public protocol InAppPurchaseProductLoader {
    typealias Result = Swift.Result<InAppPurchaseProductsResponse, Error>

    func getUUID(completion: @escaping (String?) -> Void)
    func load(request: InAppPurchaseProductLoaderRequest, completion: @escaping (Result) -> Void)
}
