//
//  LikeUpdater.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 27/12/22.
//

import Foundation

public struct LikeRequest: Equatable {
    public let feedID: String
    public let status: LikeFeed
    
    public init(feedID: String, status: LikeFeed) {
        self.feedID = feedID
        self.status = status
    }
}

public enum LikeFeed: String {
    case like = "like"
    case unlike = "unlike"
}

public protocol LikeUpdater {
    typealias Result = Swift.Result<DefaultNetworkResponse, Error>
    
    func seen(request: LikeRequest, completion: @escaping (Result) -> Void)
}
