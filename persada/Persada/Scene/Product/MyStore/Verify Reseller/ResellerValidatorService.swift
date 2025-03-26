//
//  ResellerValidatorService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class ResellerValidatorService: ResellerValidatorControllerDelegate {
    
    let loader: ResellerValidator
    var presenter: ResellerValidatorPresenter?
    
    init(loader: ResellerValidator) {
        self.loader = loader
    }
    
    func didVerifyReseller() {
        presenter?.didStartLoadingGetResellerValidator()
        loader.verify { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetResellerValidator(with: item)
            case let .failure(err):
                self.presenter?.didFinishLoadingGetResellerValidator(with: err)
            }
        }
    }
}
