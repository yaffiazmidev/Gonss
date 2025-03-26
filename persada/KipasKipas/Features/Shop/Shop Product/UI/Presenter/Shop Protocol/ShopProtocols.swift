//
//  ShopProtocols.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol ShopView {
    func display(_ viewModel: [ShopViewModel])
}

protocol ShopLoadingView {
    func display(_ viewModel: ShopLoadingViewModel)
}

protocol ShopLoadingErrorView {
    func display(_ viewModel: ShopLoadingErrorViewModel)
}
