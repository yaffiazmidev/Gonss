//
//  ShopServiceFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class ShopServiceFactory: ShopDelegate {
    
    private let categoryShop: CategoryShopControllerDelegate
    private let recommendShop: RecommendShopControllerDelegate
    private let shop: ShopControllerDelegate
    private let photoLibraryChecker: PermissionPhotoLibraryPreferencesControllerDelegate
    
    init (
        categoryShop: CategoryShopControllerDelegate,
        recommendShop: RecommendShopControllerDelegate,
        shop: ShopControllerDelegate,
        photoLibraryChecker: PermissionPhotoLibraryPreferencesControllerDelegate
    ) {
        self.categoryShop = categoryShop
        self.recommendShop = recommendShop
        self.shop = shop
        self.photoLibraryChecker = photoLibraryChecker
    }
    
    func didRequestCategoryShop(request: CategoryShopRequest) {
        categoryShop.didRequestCategoryShop(request: request)
    }
    
    func didRequestRecommendShop() {
        recommendShop.didRequestRecommendShop()
    }
    
    func didRequestShop(request: ShopRequest) {
        shop.didRequestShop(request: request)
    }
    
    func didCheckPhotoLibraryPermissionStatus() {
        photoLibraryChecker.didCheckPhotoLibraryPermissionStatus()
    }
}
