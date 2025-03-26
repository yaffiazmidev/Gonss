//
//  CouriersUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 21/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

final class CourierUIFactory {
    
    static func create(parameter: CourierParameter, dismissAction: @escaping ((_ courier: CourierItem, _ index: Int) -> Void) ) -> CourierController {
        let baseURL = URL(string: APIConstants.baseURL)!
        let loader = RemoteCourierLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())

        let controller = CourierUIComposer.couriersComposedWith(parameter: parameter, loader: loader)
        controller.dismissAction = dismissAction
        
        return controller
    }
}
