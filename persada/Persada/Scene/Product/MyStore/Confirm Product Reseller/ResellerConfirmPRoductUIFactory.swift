//
//  ResellerConfirmPRoductUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class ResellerConfirmProductUIFactory {
    
    static func create(with params: ConfirmProductParams, dismissAction: @escaping (() -> Void) ) -> ResellerConfirmProductController {
        let baseURL = URL(string: APIConstants.baseURL)!
        
        let confirm = RemoteResellerProductConfirm(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())
        let loader = RemoteUserSellerLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())
        let loaderProduct = RemoteResellerProductLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())
        let validator = RemoteResellerValidator(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())
        
        let controller = ResellerConfirmProductUIComposer.resellerConfirmComposedWith(with: params, confirm: confirm, loader: loader, loaderProduct: loaderProduct, validator: validator)
        
        controller.dismissAction = dismissAction
        
        return controller
    }
}
