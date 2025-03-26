//
//  RemoteVerifyIdentityChecker.swift
//  KipasKipasVerificationIdentity
//
//  Created by DENAZMI on 05/06/24.
//

import Foundation
import KipasKipasNetworking

public class RemoteVerifyIdentityChecker: VerifyIdentityChecker {
    
    public typealias Result = VerifyIdentityChecker.Result
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func check(completion: @escaping (Result) -> Void) {
        let request = enrich(baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteVerifyIdentityChecker.map(data, response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let item = try VerifyIdentityCheckerMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}

class VerifyIdentityCheckerMapper {
        
    struct Root: Decodable {
        let code: String
        let message: String
        let data: DataClass?
        
        struct DataClass: Decodable {
            let email: Bool?
            let phone: Bool?
            let diamond: Bool?
            let emailValue: String?
            let phoneNumberValue: String?
        }
        
        var item: VerifyIdentityCheckItem {
            return VerifyIdentityCheckItem(
                email: data?.email ?? false,
                phone: data?.phone ?? false,
                diamond: data?.diamond ?? false,
                emailValue: data?.emailValue ?? "",
                phoneNumberValue: data?.phoneNumberValue ?? ""
            )
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> VerifyIdentityCheckItem {
        
        let statusCode = response.statusCode
        
        guard statusCode == 200 else {
            
            struct Root: Decodable { let code, message: String }
            
            guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
                throw VerifyIdentityError.invalidData
            }
            
            guard response.statusCode != 429 else {
                throw VerifyIdentityError.verifyIdentityLimit
            }
            
            throw VerifyIdentityError.responseFailure(code: statusCode, message: root.message)
        }
        
        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw VerifyIdentityError.invalidData
        }
        
        return root.item
    }
}

extension RemoteVerifyIdentityChecker {
    
    private func enrich(_ baseURL: URL) -> URLRequest {
        return .url(baseURL)
            .path("/verification-identity/me/check")
            .build()
    }
}

public enum VerifyIdentityError: Error, Equatable {
    case connectivity
    case invalidData
    case responseFailure(code: Int, message: String)
    case verifyIdentityLimit
}
