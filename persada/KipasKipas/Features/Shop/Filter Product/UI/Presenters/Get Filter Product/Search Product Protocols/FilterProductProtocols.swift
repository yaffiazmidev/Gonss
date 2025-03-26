//
//  SearchProductProtocols.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol FilterProductView {
    func display(_ viewModel: [FilterProductViewModel])
}

protocol FilterProductLoadingView {
    func display(_ viewModel: FilterProductLoadingViewModel)
}

protocol FilterProductLoadingErrorView {
    func display(_ viewModel: FilterProductLoadingErrorViewModel)
}
