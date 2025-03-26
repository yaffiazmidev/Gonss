//
//  StopBecomeResellerUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class StopBecomeResellerUIComposer {
    private init() {}
    
    static func stopBecomeUserComposeWith(params: RemoveResellerParams,remover: ResellerProductRemove) -> StopBecomeResellerController {
        let removerResellerService = StopBecomeResellerService(loader: MainQueueDispatchDecorator(decoratee: remover))
        
        let controller = StopBecomeResellerController(delegate: removerResellerService, params: params)
        
        removerResellerService.presenter = StopBecomeResellerPresenter(
            successView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
