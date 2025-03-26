//
//  InputUserWeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import KipasKipasShared

// MARK: Create
extension WeakRefVirtualProxy: CreateUserView where T: CreateUserView {
    
    func display(_ viewModel: CreateUserViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CreateUserLoadingView where T: CreateUserLoadingView {
    
    func display(_ viewModel: CreateUserLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CreateUserLoadingErrorView where T: CreateUserLoadingErrorView {
    
    func display(_ viewModel: CreateUserLoadingErrorViewModel) {
        object?.display(viewModel)
    }
    
}

// MARK: Check Email
extension WeakRefVirtualProxy: EmailValidatorView where T: EmailValidatorView {
    
    func display(_ viewModel: EmailValidatorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: EmailValidatorLoadingView where T: EmailValidatorLoadingView {
    
    func display(_ viewModel: EmailValidatorLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: EmailValidatorLoadingErrorView where T: EmailValidatorLoadingErrorView {
    
    func display(_ viewModel: EmailValidatorLoadingErrorViewModel) {
        object?.display(viewModel)
    }

}

extension WeakRefVirtualProxy: EmailValidatorAlreadyExistsView where T: EmailValidatorAlreadyExistsView {
    
    func display(_ viewModel: EmailValidatorAlreadyExistsViewModel) {
        object?.display(viewModel)
    }
}

// MARK: Check Username
extension WeakRefVirtualProxy: UsernameValidatorView where T: UsernameValidatorView {
    
    func display(_ viewModel: UsernameValidatorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: UsernameValidatorLoadingView where T: UsernameValidatorLoadingView {
    
    func display(_ viewModel: UsernameValidatorLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: UsernameValidatorLoadingErrorView where T: UsernameValidatorLoadingErrorView {
    
    func display(_ viewModel: UsernameValidatorLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: UsernameValidatorAlreadyExistsView where T: UsernameValidatorAlreadyExistsView {
    
    func display(_ viewModel: UsernameValidatorAlreadyExistsViewModel) {
        object?.display(viewModel)
    }
}


// MARK: Upload
extension WeakRefVirtualProxy: UserPhotoUploadView where T: UserPhotoUploadView {
    
    func display(_ viewModel: UserPhotoUploadViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: UserPhotoUploadLoadingView where T: UserPhotoUploadLoadingView {
    
    func display(_ viewModel: UserPhotoUploadLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: UserPhotoUploadLoadingErrorView where T: UserPhotoUploadLoadingErrorView {
    
    func display(_ viewModel: UserPhotoUploadLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}
