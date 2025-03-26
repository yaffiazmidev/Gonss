//
//  UsernameValidatorViewProtocol.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol UsernameValidatorView {
    func display(_ viewModel: UsernameValidatorViewModel)
}

protocol UsernameValidatorLoadingView {
    func display(_ viewModel: UsernameValidatorLoadingViewModel)
}

protocol UsernameValidatorLoadingErrorView {
    func display(_ viewModel: UsernameValidatorLoadingErrorViewModel)
}

protocol UsernameValidatorAlreadyExistsView {
    func display(_ viewModel: UsernameValidatorAlreadyExistsViewModel)
}
