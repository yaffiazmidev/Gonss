//
//  TokenCache.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 30/03/22.
//

import Foundation

public protocol TokenCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ token: TokenItem, completion: @escaping (Result) -> Void )
}
