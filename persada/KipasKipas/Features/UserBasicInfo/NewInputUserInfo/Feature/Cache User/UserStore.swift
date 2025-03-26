//
//  UserStore.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol UserStore {
    typealias InsertionItemCompletions = (Swift.Result<Void, Error>) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ user: LocalUserItem, completion: @escaping InsertionItemCompletions)
    func retrieve() -> LocalUserItem?
    func remove()
}
