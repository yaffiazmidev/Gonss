//
//  SearchProductUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 30/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class SearchProductUIFactory {
    static func create(isPublic: Bool, categoryShop: CategoryShopItem? = nil) -> SearchProductViewController {
        let baseURL = URL(string: APIConstants.baseURL)!
        let loader = RemoteFilterProductLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient(), isPublic: isPublic)
        let controller = SearchProductUIComposer.searchProductComposedWith(loader: loader, categoryProduct: categoryShop)
        
        return controller
    }
}
