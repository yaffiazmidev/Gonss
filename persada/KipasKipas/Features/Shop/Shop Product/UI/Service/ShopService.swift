//
//  ShopService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class ShopService: ShopControllerDelegate {
    let loader: ShopLoader
    var presenter: ShopPresenter?
    
    init(loader: ShopLoader) {
        self.loader = loader
    }
    
    func didRequestShop(request: ShopRequest) {
        presenter?.didStartLoadingGetShop()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(items):
                self.presenter?.didFinishLoadingGetShop(with: items)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetShop(with: error)
            }
        }
    }
}
