//
//  CategoryShopService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class CategoryShopService: CategoryShopControllerDelegate {
    let loader: CategoryShopLoader
    var presenter: CategoryShopPresenter?
    
    init(loader: CategoryShopLoader) {
        self.loader = loader
    }
    
    func didRequestCategoryShop(request: CategoryShopRequest)  {
        presenter?.didStartLoadingGetCategoryShop()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(items):
                self.presenter?.didFinishLoadingGetCategoryShop(with: items)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetCategoryShop(with: error)
            }
        }
    }
}
