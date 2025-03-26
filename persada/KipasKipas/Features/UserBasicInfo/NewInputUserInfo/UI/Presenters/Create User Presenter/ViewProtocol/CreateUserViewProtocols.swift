//
//  CreateUserViewProtocols.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol CreateUserView {
    func display(_ viewModel: CreateUserViewModel)
}

protocol CreateUserLoadingView {
    func display(_ viewModel: CreateUserLoadingViewModel)
}

protocol CreateUserLoadingErrorView {
    func display(_ viewModel: CreateUserLoadingErrorViewModel)
}

