//
//  ResellerConfirmProductServiceFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class ResellerConfirmProductServiceFactory: ResellerConfirmProductDelegate {
    
    
    private let confirm: ResellerConfirmProductService
    private let loader: UserSellerService
    private let loaderProduct: ResellerProductService
    private let validator: ResellerValidatorService
    
    init(confirm: ResellerConfirmProductService, loader: UserSellerService, loaderProduct: ResellerProductService, validator: ResellerValidatorService) {
        self.confirm = confirm
        self.loader = loader
        self.loaderProduct = loaderProduct
        self.validator = validator
    }
    
    func didRequestUserSeller(request: UserSellerRequest) {
        loader.didRequestUserSeller(request: request)
    }
    
    func didResellerConfirmProduct(request: ResellerProductConfirmRequest) {
        confirm.didResellerConfirmProduct(request: request)
    }
    
    func didRequestResellerProduct(request: ResellerProductRequest) {
        loaderProduct.didRequestResellerProduct(request: request)
    }
    
    func didVerifyReseller() {
        validator.didVerifyReseller()
    }
}
