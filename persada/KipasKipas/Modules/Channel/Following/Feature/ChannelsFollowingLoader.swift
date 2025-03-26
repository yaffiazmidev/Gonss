//
//  ChannelsFollowingLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol ChannelsFollowingLoader {
    typealias Result = Swift.Result<ChannelsFollowingItem, Error>
    
    func load(request: ChannelsFollowingRequest, completion: @escaping (Result) -> Void)
}
