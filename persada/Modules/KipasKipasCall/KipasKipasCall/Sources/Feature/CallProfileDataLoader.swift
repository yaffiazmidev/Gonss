//
//  CallProfileDataLoader.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation

public struct CallProfileDataLoaderRequest: Equatable, Encodable {
    public let userId: String
    
    public init(userId: String) {
        self.userId = userId
    }
}

public protocol CallProfileDataLoader {
    typealias Result = Swift.Result<CallProfile, Error>
    
    func load(request: CallProfileDataLoaderRequest, completion: @escaping (Result) -> Void)
}
