//
//  RemoteQRDonationLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteQRDonationLoader: QRDonationLoader {
    private let url : URL
    private let client: HTTPClient
  
    typealias Result = QRDonationLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: QRDonationLoaderRequest, completion: @escaping (Result) -> Void) {
        let request = QREndpoint.donation(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteQRDonationLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try QRDonationItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
