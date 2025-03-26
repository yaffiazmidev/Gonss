//
//  FeedType.swift
//  FeedCleeps
//
//  Created by DENAZMI on 20/11/23.
//

import Foundation
import TUIPlayerCore
import TUIPlayerShortVideo

public enum FeedMediaType: String, Codable {
    case image = "image"
    case video = "video"
}

public enum FeedType: Int, Codable {
    case donation = 0
    case hotNews = 1
    case feed = 2
    case profile = 3
    case otherProfile = 4
    case following = 5
    case explore = 6
    case channel = 7
    case searchTop = 8
    case deletePush = 9
 
    var controllCell: TUIPlayerShortVideoControl.Type {
        switch self {
        default:
            return HotNewsViewCell.self
        }
    }
}
