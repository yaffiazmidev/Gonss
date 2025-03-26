//
//  CategoryDetailUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 30/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class CategoryDetailUIFactory {
    static func create(isPublic: Bool, categoryProduct: CategoryShopItem) -> CategoryDetailViewController {
        let baseURL = URL(string: APIConstants.baseURL)!
        let loader = RemoteFilterProductLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient(), isPublic: isPublic)
        let controller = CategoryDetailUIComposer.detailCategoryProductComposedWith(loader: loader, categoryProduct: categoryProduct)
        
        return controller
    }
}
