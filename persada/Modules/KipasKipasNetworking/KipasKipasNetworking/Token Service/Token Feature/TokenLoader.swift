//
//  TokenLoader.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 30/03/22.
//

import Foundation

public protocol TokenLoader {
    typealias Result = Swift.Result<TokenItem, Error>
    
    @discardableResult
    func load(request: TokenRequest) async throws -> TokenItem
}
