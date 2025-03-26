//
//  CourierViewProtocols.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol CourierView {
    func display(_ viewModel: CourierViewModel)
}

protocol CourierLoadingView {
    func display(_ viewModel: CourierLoadingViewModel)
}

protocol CourierLoadingErrorView {
    func display(_ viewModel: CourierLoadingErrorViewModel)
}
