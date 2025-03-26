//
//  FeedItem.swift
//  KKTUIPlayerApp
//
//  Created by DENAZMI on 27/09/23.
//

import Foundation
import TUIPlayerCore
import TUIPlayerShortVideo

class FeedItem: TUIPlayerVideoModel {
    
    var id: String?
    var likes: Int?
    var isLike: Bool?
    var account: FeedAccount?
    var post: FeedPost?
    
    init(id: String? = nil, likes: Int? = nil, isLike: Bool? = nil, account: FeedAccount? = nil, post: FeedPost? = nil) {
        self.id = id
        self.likes = likes
        self.isLike = isLike
        self.account = account
        self.post = post
    }
}

class FeedAccount {
    
    var username: String?
    
    init(username: String? = nil) {
        self.username = username
    }
}

class FeedPost {
    
    var description: String?
    var medias: [FeedMedia]?
    
    init(description: String? = nil, medias: [FeedMedia]? = nil) {
        self.description = description
        self.medias = medias
    }
}

class FeedMedia {
    
    var id: String?
    var url: String?
    var vodUrl: String?
    var vodFileId: String?
    var metadata: FeedMetadata?
    var thumbnail: FeedThumbnail?
    
    init(id: String? = nil, url: String? = nil, vodUrl: String? = nil, vodFileId: String? = nil, metadata: FeedMetadata? = nil, thumbnail: FeedThumbnail? = nil) {
        self.id = id
        self.url = url
        self.vodUrl = vodUrl
        self.vodFileId = vodFileId
        self.metadata = metadata
        self.thumbnail = thumbnail
    }
}

class FeedThumbnail {
    var small: String?
    var large: String?
    var medium: String?
    
    init(small: String? = nil, large: String? = nil, medium: String? = nil) {
        self.small = small
        self.large = large
        self.medium = medium
    }
}

class FeedMetadata {
    var duration: Double?
    
    init(duration: Double? = nil) {
        self.duration = duration
    }
}
