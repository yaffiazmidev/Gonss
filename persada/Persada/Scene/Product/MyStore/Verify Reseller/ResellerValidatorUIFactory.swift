//
//  ResellerValidatorUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class ResellerValidatorUIFactory {
    static func create() -> ResellerValidatorController {
        let baseURL = URL(string: APIConstants.baseURL)!
        let loader = RemoteResellerValidator(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())
        
        let controller = ResellerValidatorUIComposer.resellerComposedWith(loader: loader)
        return controller
        
    }
}
