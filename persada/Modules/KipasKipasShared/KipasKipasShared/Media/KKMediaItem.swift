//
//  KKMediaItem.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/11/23.
//

import UIKit

public enum KKMediaItemType {
    case video
    case photo
}

public enum KKMediaPostType {
    case feed
    case story
}

public struct KKMediaItem {
    public let data: Data?
    public let path: String
    public let type: KKMediaItemType
    public let postType: KKMediaPostType
    public let videoThumbnail: UIImage?
    public let photoThumbnail: UIImage?
    
    public init(
        data: Data?,
        path: String,
        type: KKMediaItemType,
        postType: KKMediaPostType = .feed,
        videoThumbnail: UIImage? = nil,
        photoThumbnail: UIImage? = nil
    ) {
        self.data = data
        self.path = path
        self.type = type
        self.postType = postType
        self.videoThumbnail = videoThumbnail
        self.photoThumbnail = photoThumbnail
    }
}
