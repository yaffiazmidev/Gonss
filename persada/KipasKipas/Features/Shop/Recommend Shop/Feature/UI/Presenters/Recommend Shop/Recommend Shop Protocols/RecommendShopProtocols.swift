//
//  RecommendShopProtocols.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol RecommendShopView {
    func display(_ viewModel: [RecommendShopViewModel])
}

protocol RecommendShopLoadingView {
    func display(_ viewModel: RecommendShopLoadingViewModel)
}

protocol RecommendShopLoadingErrorView {
    func display(_ viewModel: RecommendShopLoadingErrorViewModel)
}
