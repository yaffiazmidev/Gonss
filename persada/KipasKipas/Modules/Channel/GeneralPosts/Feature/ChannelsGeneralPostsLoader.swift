//
//  ChannelsGeneralPostsLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol ChannelsGeneralPostsLoader {
    typealias Result = Swift.Result<ChannelsGeneralPostsItem, Error>
    
    func load(request: ChannelsGeneralPostsRequest, completion: @escaping (Result) -> Void)
}
