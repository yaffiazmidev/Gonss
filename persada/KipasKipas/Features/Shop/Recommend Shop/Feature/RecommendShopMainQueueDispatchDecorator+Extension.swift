//
//  RecommendShopMainQueueDispatchDecorator+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: RecommendShopLoader where T == RecommendShopLoader {
    func load(completion: @escaping (RecommendShopLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
