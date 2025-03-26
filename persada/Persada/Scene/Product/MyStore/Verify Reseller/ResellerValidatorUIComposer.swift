//
//  ResellerValidatorUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class ResellerValidatorUIComposer {
    private init() {}
    
    static func resellerComposedWith(loader: ResellerValidator) -> ResellerValidatorController {
        
        let loaderService = ResellerValidatorService(loader: MainQueueDispatchDecorator(decoratee: loader))
        let controller = ResellerValidatorController(delegate: loaderService)
        
        loaderService.presenter = ResellerValidatorPresenter(
            successView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
