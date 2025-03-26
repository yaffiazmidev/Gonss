//
//  StopBecomeResellerUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class StopBecomeResellerUIFactory {
    
    static func create(params: RemoveResellerParams, dismissAction: @escaping (() -> Void)) -> StopBecomeResellerController {
        let baseURL = URL(string: APIConstants.baseURL)!
        
        let removeReseller = RemoteResellerProductRemove(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())
        
        let controller = StopBecomeResellerUIComposer.stopBecomeUserComposeWith(params: params, remover: removeReseller)
        controller.dismissAction = dismissAction
        
        return controller
    }
}

