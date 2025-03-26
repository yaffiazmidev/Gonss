//
//  MediaUploadManager.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/05/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking
import KipasKipasShared

public class MediaUploadManager: MediaUploader {
    private var ossUploader: MediaUploader?
    private var cosUploader: MediaUploader?
    private var vodUploader: MediaUploader?
    
    public var videoUseVOD: Bool = true
    public var ossUsePublic: Bool = true {
        didSet {
//            ossUploader = nil
        }
    }
    
    public typealias Result = MediaUploader.Result
    
    public init() {}
    
    public init(ossUploader: MediaUploader? = nil, cosUploader: MediaUploader? = nil, vodUploader: MediaUploader? = nil, videoUseVOD: Bool = true, ossUsePublic: Bool = true) {
        self.ossUploader = ossUploader
        self.cosUploader = cosUploader
        self.vodUploader = vodUploader
        self.videoUseVOD = videoUseVOD
        self.ossUsePublic = ossUsePublic
    }
    
    public func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void) {
        if let type = KKMediaItemExtension.from(request.ext) {
            if type == .photo {
                let request = AuthenticatedMediaUploaderRequest.from(
                    request: request,
                    username: UploadConstants.Alibaba.stsUsername,
                    password: UploadConstants.Alibaba.stsPassword
                )
                
                print("**@@ createOSSUploader.upload -- 1")

                createOSSUploader().upload(request: request, completion: completion)
            } else {
                if videoUseVOD {
                    let request = AuthenticatedMediaUploaderRequest.from(
                        request: request,
                        username: UploadConstants.Tencent.VOD.Transcode.username,
                        password: UploadConstants.Tencent.VOD.Transcode.password
                    )
                    
                    createVODUploader().upload(request: request, completion: completion)
                } else {
                    createCOSUploader().upload(request: request, completion: completion)
                }
            }
        }
    }
    
    public func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void, uploadProgress: @escaping (Double) -> Void) {
        if let type = KKMediaItemExtension.from(request.ext) {
            if type == .photo {
                
                let request = AuthenticatedMediaUploaderRequest.from(
                    request: request, 
                    username: UploadConstants.Alibaba.stsUsername,
                    password: UploadConstants.Alibaba.stsPassword
                )
                
                print("**@@ createOSSUploader.upload -- 2")
                
                createOSSUploader().upload(request: request, completion: completion, uploadProgress: uploadProgress)
            } else {
                if videoUseVOD {
                    let request = AuthenticatedMediaUploaderRequest.from(
                        request: request,
                        username: UploadConstants.Tencent.VOD.Transcode.username,
                        password: UploadConstants.Tencent.VOD.Transcode.password
                    )
                    
                    createVODUploader().upload(request: request, completion: completion, uploadProgress: uploadProgress)
                } else {
                    createCOSUploader().upload(request: request, completion: completion, uploadProgress: uploadProgress)
                }
            }
        }
    }
}

fileprivate extension MediaUploadManager {
    private func createOSSUploader() -> MediaUploader {

        // PE-14268        
//        if let uploader = self.ossUploader {
//            return uploader
//        }

        let uploader = OSSClientFactory.Alibaba.create(usePublic: true)
                
        self.ossUploader = uploader
        return uploader
    }
    
    private func createCOSUploader() -> MediaUploader {
        if let uploader = self.cosUploader {
            return uploader
        }
        let uploader = TencentCOSMediaUploader()
        self.cosUploader = uploader
        return uploader
    }
    
    private func createVODUploader() -> MediaUploader {
        if let uploader = self.vodUploader {
            return uploader
        }
        
        let signatureUrl = URL(string: UploadConstants.Tencent.VOD.signatureEndpoint)!
        let transcodeUrl = URL(string: UploadConstants.Tencent.VOD.Transcode.endpoint)!
        let client = HTTPClientFactory.makeHTTPClient()
        let uploader = TencentVODMediaUploader(signatureUrl: signatureUrl, transcodeUrl: transcodeUrl, client: client)
        self.vodUploader = uploader
        return uploader
    }
}
