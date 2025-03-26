//
//  MediaUploaderResult.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

public struct MediaUploaderResult {
    public let tmpUrl: String
    public let url: String
    public let vod: MediaUploaderVODResult?
    
    public init(tmpUrl: String, url: String, vod: MediaUploaderVODResult? = nil) {
        self.tmpUrl = tmpUrl
        self.url = url
        self.vod = vod
    }
}

public struct MediaUploaderVODResult {
    public let id: String
    public let url: String
    
    public init(id: String, url: String) {
        self.id = id
        self.url = url
    }
}
