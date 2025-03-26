//
//  DIContainer.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 01/08/23.
//

import Foundation

public class DIContainer {
    
    public static let shared = DIContainer()
    
    public func apiDTS(baseUrl: String) -> DataTransferService {
        let config = ApiDataNetworkConfig(baseURL: URL(string: baseUrl)!)
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }
    
    public func apiAUTHDTS(baseUrl: String, authToken: String?) -> DataTransferService {
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: baseUrl)!,
            headers: ["Content-Type": "application/json",
                      "Authorization": "Bearer \(authToken ?? "")"]
        )
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }
}
