//
//  ShopWeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 25/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

// MARK: Get
extension WeakRefVirtualProxy: ShopView where T: ShopView {
    
    func display(_ viewModel: [ShopViewModel]) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ShopLoadingView where T: ShopLoadingView {
    
    func display(_ viewModel: ShopLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ShopLoadingErrorView where T: ShopLoadingErrorView {
    
    func display(_ viewModel: ShopLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ShopViewControllerDelegate where T: ShopViewControllerDelegate {
    func displayProductSpecialDiscount(with items: [RemoteProductEtalaseData]) {
        object?.displayProductSpecialDiscount(with: items)
    }
    
    func displayErrorGetProductSpecialDiscount(with message: String) {
        object?.displayErrorGetProductSpecialDiscount(with: message)
    }
    
    func displayStores(with items: [RemoteStoreItemData]) {
        object?.displayStores(with: items)
    }
    
    func displayErrorGetStores(with message: String) {
        object?.displayErrorGetStores(with: message)
    }
}


