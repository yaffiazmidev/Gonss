//
//  ShopUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class ShopUIFactory {
    
    static func create(isPublic: Bool) -> ShopViewController {
        
        let baseURL = URL(string: APIConstants.baseURL)!
        let categoryShop = RemoteCategoryShopLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient(), isPublic: isPublic)
        let recommendShop = RemoteRecommendShopLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient(), isPublic: isPublic)
        let shop = RemoteShopLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient(), isPublic: isPublic)
        let photoLibraryChecker = SystemPhotoLibraryPreferencesPermissionChecker()
        
        let controller = ShopUIComposer.shopComposerWith(
            category: categoryShop,
            recommend: recommendShop,
            shop: shop,
            photoLibraryChecker: photoLibraryChecker)
        
        return controller
    }
}
