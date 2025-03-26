//
//  CategoryShopUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation


final class CategoryShopUIFactory {
    static func create(isPublic: Bool) -> CategoryShopController {
        
        let baseURL = URL(string: APIConstants.baseURL)!
        let loader = RemoteCategoryShopLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient(), isPublic: isPublic)
        
        let controller = CategoryShopUIComposer.categoryShopComposedWith(loader: loader)
        
        return controller
    }
}
