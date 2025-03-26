//
//  SelectCategoryShopUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class SelectCategoryShopUIFactory {
    static func create(isPublic: Bool) -> SelectCategoryShopController {
        
        let baseURL = URL(string: APIConstants.baseURL)!
        let loader = RemoteCategoryShopLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient(), isPublic: isPublic)
        
        let controller = SelectCategoryShopUIComposer.categoryShopComposedWith(loader: loader)
        
        return controller
    }
}
