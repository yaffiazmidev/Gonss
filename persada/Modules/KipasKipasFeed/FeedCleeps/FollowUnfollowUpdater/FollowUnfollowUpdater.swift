//
//  FollowUnfollowUpdater.swift
//  FeedCleeps
//
//  Created by DENAZMI on 05/12/22.
//

import Foundation
import KipasKipasShared

public struct FollowUnfollowUpdaterRequest: Equatable {
    public var id: String
    public var isFollow: Bool
    
    public init(id: String, isFollow: Bool) {
        self.id = id
        self.isFollow = isFollow
    }
}

public protocol FollowUnfollowUpdater {
    typealias Result = Swift.Result<DefaultItem, Error>
    
    func load(request: FollowUnfollowUpdaterRequest, completion: @escaping (Result) -> Void)
}

extension MainQueueDispatchDecorator: FollowUnfollowUpdater where T == FollowUnfollowUpdater {
    public func load(request: FollowUnfollowUpdaterRequest, completion: @escaping (Swift.Result<DefaultItem, Error>) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
