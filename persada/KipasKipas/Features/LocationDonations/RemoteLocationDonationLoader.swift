//
//  RemoteLocationDonationLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteLocationDonation: LocationDonationLoader {
    private let url: URL
    private let client: HTTPClient
    public typealias Result = LocationDonationLoader.Result
    
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: LocationDonationRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = LocationDonationEndpoint.get(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteLocationDonation.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try LocationDonationItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

class LocationDonationItemMapper {
    
    private struct Root: Codable {
        private let code, message: String
        private let data: LocationDonationData?
        
        private struct LocationDonationData: Codable, Equatable {
            let content: [Location]?
        }
        
        private struct Location: Codable, Equatable {
            let id, name, code: String?
        }
        
        var locations: [LocationDonationItem] {
            return data?.content?.compactMap({
                return LocationDonationItem(
                    id: $0.id ?? "",
                    name: $0.name ?? "",
                    code: $0.code ?? ""
                )
            }) ?? []
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [LocationDonationItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.locations
    }
}
