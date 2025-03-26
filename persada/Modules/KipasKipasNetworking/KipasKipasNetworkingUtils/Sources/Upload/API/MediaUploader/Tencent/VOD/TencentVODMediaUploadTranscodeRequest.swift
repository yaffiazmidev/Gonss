//
//  TencentVODMediaUploadTranscodeRequest.swift
//  KipasKipasNetworkingUtils
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/11/23.
//

import Foundation

public struct TencentVODMediaUploadTranscodeRequest: Codable {
    public let videoId: String
    public let transcodeId: Int
    
    public init(videoId: String, transcodeId: Int) {
        self.videoId = videoId
        self.transcodeId = transcodeId
    }
    
    enum CodingKeys: String, CodingKey {
        case videoId = "file_id"
        case transcodeId = "transcode_template_id"
    }
}
