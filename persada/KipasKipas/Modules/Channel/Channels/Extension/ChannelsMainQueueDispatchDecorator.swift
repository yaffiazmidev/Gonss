//
//  ChannelsMainQueueDispatchDecorator.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

extension MainQueueDispatchDecorator: ChannelsLoader where T == ChannelsLoader {
    
    func load(request: ChannelsRequest, completion: @escaping (ChannelsLoader.Result) -> Void) {
        decoratee.load(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
