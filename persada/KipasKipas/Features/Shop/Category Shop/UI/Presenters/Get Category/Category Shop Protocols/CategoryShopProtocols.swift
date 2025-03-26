//
//  CategoryShopProtocols.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol CategoryShopView {
    func display(_ viewModel: CategoryShopViewModel)
}

protocol CategoryShopLoadingView {
    func display(_ viewModel: CategoryShopLoadingViewModel)
}

protocol CategoryShopLoadingErrorView {
    func display(_ viewModel: CategoryShopLoadingErrorViewModel)
}
