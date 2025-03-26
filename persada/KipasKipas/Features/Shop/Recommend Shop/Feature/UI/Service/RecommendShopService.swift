//
//  RecommendShopService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class RecommendShopService: RecommendShopControllerDelegate {
    let loader: RecommendShopLoader
    var presenter: RecommendShopPresenter?
    
    init(loader: RecommendShopLoader) {
        self.loader = loader
    }
    
    func didRequestRecommendShop()  {
        presenter?.didStartLoadingGetRecommendShop()
        loader.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(items):
                self.presenter?.didFinishLoadingGetRecommendShop(with: items)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetRecommendShop(with: error)
            }
        }
    }
}



