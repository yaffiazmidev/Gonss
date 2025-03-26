//
//  ChannelsFollowingMainQueueDispatchDecorator.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

extension MainQueueDispatchDecorator: ChannelsFollowingLoader where T == ChannelsFollowingLoader {
    
    func load(request: ChannelsFollowingRequest, completion: @escaping (ChannelsFollowingLoader.Result) -> Void) {
        decoratee.load(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
