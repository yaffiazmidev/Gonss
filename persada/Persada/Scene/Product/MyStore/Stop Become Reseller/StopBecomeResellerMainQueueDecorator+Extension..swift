//
//  StopBecomeResellerMainQueueDecorator+Extension..swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: ResellerProductRemove where T == ResellerProductRemove {
    
    func remove(request: ResellerProductRemoveRequest, completion: @escaping (ResellerProductRemove.Result) -> Void) {
        decoratee.remove(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
