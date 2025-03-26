//
//  StopBecomeResellerService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class StopBecomeResellerService: StopBecomeResellerControllerDelegate {
    let loader: ResellerProductRemove
    var presenter: StopBecomeResellerPresenter?
    
    init(loader: ResellerProductRemove) {
        self.loader = loader
    }
    
    func didStopBecomeReseller(request: ResellerProductRemoveRequest) {
        presenter?.didStartLoadingGetStopBecomeReseller()
        loader.remove(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetStopBecomeReseller(with: ResellerProductDefaultItem(message: item))
            case let .failure(error):
                self.presenter?.didFinishLoadingGetStopBecomeReseller(with: error)
            }
        }
    }
}
