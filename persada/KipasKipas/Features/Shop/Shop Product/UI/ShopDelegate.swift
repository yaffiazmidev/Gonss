//
//  ShopDelegate.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol ShopControllerDelegate {
    func didRequestShop(request: ShopRequest)
}

typealias ShopDelegate = RecommendShopControllerDelegate & CategoryShopControllerDelegate & ShopControllerDelegate & PermissionPhotoLibraryPreferencesControllerDelegate
