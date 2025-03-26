//
//  EmailValidatorViewProtocol.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol EmailValidatorView {
    func display(_ viewModel: EmailValidatorViewModel)
}

protocol EmailValidatorLoadingView {
    func display(_ viewModel: EmailValidatorLoadingViewModel)
}

protocol EmailValidatorLoadingErrorView {
    func display(_ viewModel: EmailValidatorLoadingErrorViewModel)
}

protocol EmailValidatorAlreadyExistsView {
    func display(_ viewModel: EmailValidatorAlreadyExistsViewModel)
}
