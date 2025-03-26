//
//  ChannelDetailLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol ChannelDetailLoader {
    typealias Result = Swift.Result<ChannelDetailItem, Error>
    
    func load(request: ChannelDetailRequest, completion: @escaping (Result) -> Void)
}
