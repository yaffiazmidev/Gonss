//
//  CategoryShopMainQueueDispatchDecorator+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: CategoryShopLoader where T == CategoryShopLoader {
    func load(request: CategoryShopRequest, completion: @escaping (CategoryShopLoader.Result) -> Void ) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
