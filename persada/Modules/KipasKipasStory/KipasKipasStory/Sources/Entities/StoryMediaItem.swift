//
//  StoryMediaItem.swift
//  KipasKipasStory
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/06/24.
//

import Foundation

public struct StoryMediaItem: Codable, Equatable {
    public let id: String
    public let storyId: String
    public let type: String
    public let url: String
    public let thumbnail: StoryMediaThumbnailItem
    public let metadata: StoryMediaMetadataItem
    public let isHlsReady: Bool?
    public let hlsUrl: String?
    public let isMp4Ready: Bool?
    public let vodFileId: String?
    public let vodUrl: String?
    
    public init(id: String, storyId: String, type: String, url: String, thumbnail: StoryMediaThumbnailItem, metadata: StoryMediaMetadataItem, isHlsReady: Bool?, hlsUrl: String?, isMp4Ready: Bool?, vodFileId: String?, vodUrl: String?) {
        self.id = id
        self.storyId = storyId
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.isHlsReady = isHlsReady
        self.hlsUrl = hlsUrl
        self.isMp4Ready = isMp4Ready
        self.vodFileId = vodFileId
        self.vodUrl = vodUrl
    }
}

public struct StoryMediaThumbnailItem: Codable, Equatable {
    public let large: String
    public let medium: String
    public let small: String
    
    public init(large: String, medium: String, small: String) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}

public struct StoryMediaMetadataItem: Codable, Equatable {
    public let width: String
    public let height: String
    public let size: String
    public let duration: Double?
    
    public init(width: String, height: String, size: String, duration: Double?) {
        self.width = width
        self.height = height
        self.size = size
        self.duration = duration
    }
}
