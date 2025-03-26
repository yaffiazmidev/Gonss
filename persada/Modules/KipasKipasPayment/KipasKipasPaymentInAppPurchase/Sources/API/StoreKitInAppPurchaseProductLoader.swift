import Foundation
import StoreKit
import KipasKipasNetworking

public class StoreKitInAppPurchaseProductLoader: NSObject, InAppPurchaseProductLoader {
    public typealias Result = InAppPurchaseProductLoader.Result
    private var completion: ((Result) -> Void)? = nil
    
    private let baseURL: URL
    private let client: HTTPClient
    
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func load(request: InAppPurchaseProductLoaderRequest, completion: @escaping (Result) -> Void) {
        self.completion = completion
        let productIDs = Set(request.identifiers)
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    public func getUUID(completion: @escaping (String?) -> Void) {
        let url = baseURL.appendingPathComponent("account")
            .appendingPathComponent("info")
            .appendingPathComponent("uuid")
        
        let request = URLRequest(url: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let mapped = try Mapper<InAppPurchaseUUID>.map(data, from: response)
                completion(mapped.data)
            } catch {
                completion(nil)
            }
        }
    }
}

extension StoreKitInAppPurchaseProductLoader: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        completion?(.success(InAppPurchaseProductMapper.map(from: response)))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        completion?(.failure(error))
    }
}
