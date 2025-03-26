//
//  ChannelsGeneralPostsChannelsMainQueueDispatchDecorator.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

extension MainQueueDispatchDecorator: ChannelsGeneralPostsLoader where T == ChannelsGeneralPostsLoader {
    
    func load(request: ChannelsGeneralPostsRequest, completion: @escaping (ChannelsGeneralPostsLoader.Result) -> Void) {
        decoratee.load(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
