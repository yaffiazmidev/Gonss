//
//  ResellerProductService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class ResellerProductService: ResellerProductControllerDelegate {
    let loader: ResellerProductLoader
    var presenter: ResellerProductPresenter?
    
    init(loader: ResellerProductLoader) {
        self.loader = loader
    }
    
    func didRequestResellerProduct(request: ResellerProductRequest) {
        presenter?.didStartLoadingGetResellerProduct()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.presenter?.didFinishLoadingGetResellerProduct(with: error)
            case let .success(item):
                self.presenter?.didFinishLoadingGetResellerProduct(with: item)
            }
        }
    }
}
