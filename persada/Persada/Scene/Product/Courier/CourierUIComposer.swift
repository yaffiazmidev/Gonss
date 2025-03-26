//
//  CourierUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 21/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class CourierUIComposer {
    private init() {}
    
    internal static func couriersComposedWith(parameter: CourierParameter,loader: CourierLoader) -> CourierController {
        let loaderService = CourierService(loader: MainQueueDispatchDecorator(decoratee: loader))
        let controller = CourierController(delegate: loaderService, parameter: parameter)
        
        loaderService.presenter = CourierPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
