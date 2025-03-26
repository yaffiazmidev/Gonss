//
//  CourierService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 21/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class CourierService: CourierViewControllerDelegate {
    
    let loader: CourierLoader
    var presenter: CourierPresenter?
    
    init(loader: CourierLoader) {
        self.loader = loader
    }
    
    func didRequestCouriers(request: CourierRequest) {
        presenter?.didStartLoadingGetCouriers()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
        
            switch result {
            case let .success(courierItems):
                self.presenter?.didFinishLoadingGetCouriers(with: courierItems)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetCouriers(with: error)
            }
        }
    }
}
