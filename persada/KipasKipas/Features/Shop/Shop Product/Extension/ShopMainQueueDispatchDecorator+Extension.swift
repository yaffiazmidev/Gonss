//
//  ShopMainQueueDispatchDecorator+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: ShopLoader where T == ShopLoader {
    func load(request: ShopRequest, completion: @escaping (ShopLoader.Result) -> Void ) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
