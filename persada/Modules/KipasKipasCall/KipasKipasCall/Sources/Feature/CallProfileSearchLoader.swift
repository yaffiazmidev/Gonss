//
//  CallProfileSearchLoader.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation

public struct CallProfileSearchLoaderRequest: Equatable, Encodable {
    public let username: String
    
    public init(username: String) {
        self.username = username
    }
}

public protocol CallProfileSearchLoader {
    typealias Result = Swift.Result<[CallProfile], Error>
    
    func load(request: CallProfileSearchLoaderRequest, completion: @escaping (Result) -> Void)
}
