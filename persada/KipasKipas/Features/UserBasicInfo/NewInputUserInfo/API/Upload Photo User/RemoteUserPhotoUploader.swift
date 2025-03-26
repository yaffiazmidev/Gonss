//
//  RemoteUserPhotoUploader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class RemoteUserPhotoUploader: UserPhotoUploader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = UserPhotoUploader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func upload(request: UserPhotoUploadRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = InputUserEndpoint.upload(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteUserPhotoUploader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try UserPhotoUploadItemMapper.map(data, from: response)
            return .success(item)
        } catch  {
            return .failure(error)
        }
    }
}
