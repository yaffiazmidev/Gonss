//
//  RemoteFollowingSuggestItem.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/02/24.
//

import Foundation

public struct RemoteFollowingSuggestItem: Codable {
    let account: RemoteUserProfileData?
    let feeds: [RemoteFeedItemContent]?
}
