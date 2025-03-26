//
//  TokenStore.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 30/03/22.
//

import Foundation

public protocol TokenStore {
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletions = (InsertionResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ token: LocalTokenItem, completion: @escaping InsertionCompletions)
        
    func retrieve() -> LocalTokenItem?
    func remove()
}
