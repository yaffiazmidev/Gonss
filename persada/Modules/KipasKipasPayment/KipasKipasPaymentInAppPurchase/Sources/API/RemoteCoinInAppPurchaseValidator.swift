//
//  RemoteCoinInAppPurchaseValidator.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation
import KipasKipasNetworking

public class RemoteCoinInAppPurchaseValidator: CoinInAppPurchaseValidator {
    
    private let url : URL
    private let client: HTTPClient
    
    public typealias Result = CoinInAppPurchaseValidator.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func validate(request: CoinInAppPurchaseValidatorRequest, completion: @escaping (Result) -> Void) {
        let request = InAppPurchaseValidateEndpoint.coin(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteCoinInAppPurchaseValidator.map(data, from: response))
            } catch {
                completion(.failure(CoinInAppPurchaseValidateError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try CoinInAppPurchaseValidateMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

