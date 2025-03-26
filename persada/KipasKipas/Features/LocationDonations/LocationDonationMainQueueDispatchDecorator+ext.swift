//
//  LocationDonationMainQueueDispatchDecorator+ext.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 04/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: LocationDonationLoader where T == LocationDonationLoader {
    func load(request: LocationDonationRequest, completion: @escaping (LocationDonationLoader.Result) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
