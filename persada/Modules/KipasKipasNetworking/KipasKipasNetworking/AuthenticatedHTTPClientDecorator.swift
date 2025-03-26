import Foundation
import UIKit

public class AuthenticatedHTTPClientDecorator: HTTPClient {
    
    private let decoratee: HTTPClient
    private let cache: TokenStore
    private let tokenLoader: TokenLoader
    
    public init(decoratee: HTTPClient, cache: TokenStore, loader: TokenLoader) {
        self.decoratee = decoratee
        self.cache = cache
        self.tokenLoader = loader
    }
    
    public func request(from request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        guard let token = cache.retrieve() else {
            return try await decoratee.request(from: request)
        }
        
        let signedRequest = enrich(request, token: token.accessToken)
        
        do {
            let (data, response) = try await decoratee.request(from: signedRequest)
            if response.statusCode == 401 {
                let newToken = try await tokenLoader.load(request: .init(refresh_token: token.refreshToken))
                let newSignedRequest = enrich(request, token: newToken.accessToken)
                return try await decoratee.request(from: newSignedRequest)
                
            } else {
                return (data, response)
            }
        } catch {
            throw error
        }
    }
}

private extension AuthenticatedHTTPClientDecorator {
    func enrich(_ request: URLRequest, token: String) -> URLRequest {
        var request = request
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField:"Authorization")
        request.setValue(UIDevice.modelName, forHTTPHeaderField: "model")
        guard let requestURL = request.url,
              let urlComponents = URLComponents(string: requestURL.absoluteString) else {
            return request
        }
        
        
        guard let authenticatedRequestURL = urlComponents.url else { return request }
        
        var signedRequest = request
        signedRequest.url = authenticatedRequestURL
        return signedRequest
    }
}
