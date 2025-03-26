//
//  FilterProductService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class FilterProductService: FilterProductControllerDelegate {
    
    let loader: FilterProductLoader
    var presenter: FilterProductPresenter?
    
    init(loader: FilterProductLoader) {
        self.loader = loader
    }
    
    func didRequestFilterProduct(request: FilterProductRequest)  {
        presenter?.didStartLoadingGetFilterProduct()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(items):
                self.presenter?.didFinishLoadingGetFilterProduct(with: items)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetFilterProduct(with: error)
            }
        }
    }
}
