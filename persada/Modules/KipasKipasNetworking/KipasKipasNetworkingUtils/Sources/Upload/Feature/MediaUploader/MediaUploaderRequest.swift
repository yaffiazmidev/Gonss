//
//  MediaUploaderRequest.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

public protocol MediaUploaderRequestable {
    var media: Data { get }
    var ext: String { get }
}

public struct MediaUploaderRequest: MediaUploaderRequestable {
    public var media: Data
    public var ext: String
    
    public init(media: Data, ext: String) {
        self.media = media
        self.ext = ext
    }
}
