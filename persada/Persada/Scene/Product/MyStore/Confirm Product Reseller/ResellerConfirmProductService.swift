//
//  ResellerConfirmProductService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class ResellerConfirmProductService: ResellerConfirmProductControllerDelegate {
    
    private let confirm: ResellerProductConfirm
    var presenter: ResellerConfirmProductPresenter?
    
    init(confirm: ResellerProductConfirm) {
        self.confirm = confirm
    }
    
    func didResellerConfirmProduct(request: ResellerProductConfirmRequest) {
        presenter?.didStartLoadingGetResellerConfirmProduct()
        confirm.confirm(request: request) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(userItem):
                self.presenter?.didFinishLoadingGetResellerConfirmProduct(with: userItem)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetResellerConfirmProduct(with: error)
            }
        }
    }
}
