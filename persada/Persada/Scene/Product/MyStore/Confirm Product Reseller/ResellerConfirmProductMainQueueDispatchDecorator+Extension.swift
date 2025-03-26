//
//  ResellerConfirmProductMainQueueDispatchDecorator+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

extension MainQueueDispatchDecorator: ResellerProductConfirm where T == ResellerProductConfirm {
    func confirm(request: ResellerProductConfirmRequest, completion: @escaping (ResellerProductConfirm.Result) -> Void) {
        decoratee.confirm(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: UserSellerLoader where T == UserSellerLoader {
    func load(request: UserSellerRequest, completion: @escaping (UserSellerLoader.Result) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: ResellerProductLoader where T == ResellerProductLoader {
    func load(request: ResellerProductRequest, completion: @escaping (ResellerProductLoader.Result) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
