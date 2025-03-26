//
//  UserSellerService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class UserSellerService: UserSellerControllerDelegate {
    
    let loader: UserSellerLoader
    var presenter: UserSellerPresenter?
    
    init(loader: UserSellerLoader) {
        self.loader = loader
    }
    
    func didRequestUserSeller(request: UserSellerRequest) {
        presenter?.didStartLoadingGetUserSeller()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetUserSeller(with: item)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetUserSeller(with: error)
            }
        }
    }
}
