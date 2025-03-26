//
//  RemoteVerifyIdentityStatusLoader.swift
//  KipasKipasVerificationIdentity
//
//  Created by DENAZMI on 09/06/24.
//

import Foundation
import KipasKipasNetworking

public class RemoteVerifyIdentityStatusLoader: VerifyIdentityStatusLoader {
    
    public typealias Result = VerifyIdentityStatusLoader.Result
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        let request = enrich(baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteVerifyIdentityStatusLoader.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

private extension RemoteVerifyIdentityStatusLoader {
    private func enrich(_ baseURL: URL) -> URLRequest {
        return .url(baseURL)
            .path("/verification-identity/me")
            .build()
    }
}

private extension RemoteVerifyIdentityStatusLoader {
    
    struct DataClass: Codable {
        public let verifId: String?
        public let accountId: String?
        public let submitAt: Int?
        public let submitCount: Int?
        public let type: String?
        public let country: String?
        public let accountName: String?
        public let birthDate: String?
        public let vendorVerificationStatus: String?
        public let adminVerificationStatus: String?
        public let identityUrl: String?
        public let selfieUrl: String?
        public let vendorUniqueId: String?
        public let username: String?
        public let photo: String?
        public let isVerified: Bool?
        public let reason: String?
        public let reasonCategory: String?
        public let accountPhoto: String?
        public let phone: String?
        public let email: String?
        public let isPhoneNumberRevision: Bool?
        public let isEmailRevision: Bool?
        
        public var item: VerifyIdentityStatusItem {
            return VerifyIdentityStatusItem(
                verifId: verifId ?? "",
                accountId: accountId ?? "",
                submitAt: submitAt ?? 0,
                submitCount: submitCount ?? 0,
                type: type ?? "",
                country: country ?? "",
                accountName: accountName ?? "",
                birthDate: birthDate ?? "",
                vendorVerificationStatus: vendorVerificationStatus ?? "",
                adminVerificationStatus: adminVerificationStatus ?? "",
                identityUrl: identityUrl ?? "",
                selfieUrl: selfieUrl ?? "",
                vendorUniqueId: vendorUniqueId ?? "",
                username: username ?? "",
                photo: photo ?? "",
                isVerified: isVerified ?? false,
                reason: reason ?? "",
                reasonCategory: reasonCategory ?? "",
                accountPhoto: accountPhoto ?? "",
                phone: phone ?? "",
                email: email ?? "",
                isPhoneNumberRevision: isPhoneNumberRevision ?? false,
                isEmailRevision: isEmailRevision ?? false
            )
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let response = try Mapper<Root<DataClass>>.map(data, from: response)
            return .success(response.data.item)
        } catch {
            return .failure(error)
        }
    }
}
