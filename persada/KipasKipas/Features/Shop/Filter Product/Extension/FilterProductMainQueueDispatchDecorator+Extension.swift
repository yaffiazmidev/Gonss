//
//  SearchProductMainQueueDispatchDecorator+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: FilterProductLoader where T == FilterProductLoader {
    func load(request: FilterProductRequest, completion: @escaping (FilterProductLoader.Result) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
