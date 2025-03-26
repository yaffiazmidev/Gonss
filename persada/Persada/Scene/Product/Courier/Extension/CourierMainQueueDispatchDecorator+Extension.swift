//
//  CourierMainQueueDispatchDecorator+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 21/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: CourierLoader where T == CourierLoader {
    func load(request: CourierRequest, completion: @escaping (CourierLoader.Result) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
