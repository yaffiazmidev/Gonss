//
//  ChannelsLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol ChannelsLoader {
    typealias Result = Swift.Result<ChannelsItem, Error>
    
    func load(request: ChannelsRequest, completion: @escaping (Result) -> Void)
}
