//
//  FilterProductUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class FilterProductUIFactory {
    static func create(isPublic: Bool, productCategoryId: String? = nil) -> FilterProductController {
        let baseURL = URL(string: APIConstants.baseURL)!
        let loader = RemoteFilterProductLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient(), isPublic: isPublic)
        
        let controller = FilterProductUIComposer.searchProductComposedWith(loader: loader, productCategoryId: productCategoryId)
        
        return controller
    }
}
