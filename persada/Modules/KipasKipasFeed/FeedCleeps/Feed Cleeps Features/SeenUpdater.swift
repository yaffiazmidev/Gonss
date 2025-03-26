//
//  SeenUpdater.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 27/12/22.
//

import Foundation

public struct SeenRequest: Equatable {
    public let feedID: String
    
    public init(feedID: String) {
        self.feedID = feedID
    }
}

public protocol SeenUpdater {
    typealias Result = Swift.Result<DefaultNetworkResponse, Error>
    
    func load(request: SeenRequest, completion: @escaping (Result) -> Void)
}
