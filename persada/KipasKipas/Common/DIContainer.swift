//
//  DIContainer.swift
//  KipasKipas
//
//  Created by DENAZMI on 13/02/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class DIContainer {
    static let shared = DIContainer()

    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: APIConstants.baseURL)!)
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    lazy var defaultAPIDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: APIConstants.baseURL)!)
        let apiDataNetwork = KKDefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    lazy var toolsDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: "https://tools.kipaskipas.com/api/v1/")!
        )
        let apiDataNetwork = KKDefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
}
