//
//  ChannelDetailMainQueueDispatchDecorator.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

extension MainQueueDispatchDecorator: ChannelDetailLoader where T == ChannelDetailLoader {
    
    func load(request: ChannelDetailRequest, completion: @escaping (ChannelDetailLoader.Result) -> Void) {
        decoratee.load(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
