//
//  UploadProgress.swift
//  KipasKipas
//
//  Created by PT.Koanba on 08/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit
import KipasKipasNetworkingUtils
import KipasKipasShared

class UploadProgressView: UIView {
    
    enum UploadType {
        case story
        case feed
    }
    
    var latestUploadType: UploadType = .story
    var uploader: MediaUploader?
    
    private let downloadManager = DownloadManager()
    private let network = UploadNetworkModel()
    private var selected : Product?
    private var item : KKMediaItem?
    
    private var product : [MediaPostProductId] = []
    private var media : ResponseMedia? = nil
    var param : PostFeedParam?
    
    private var isUpload = false
    private var isUploadFeed = false
    private var isFromFeed = false
    private var isExecuted = false
    private var isDone = false
    
    private var currentProgress = 0.0
    var actionFinishUpload : () -> () = { }
    var stopUpload = { }
    
    private lazy var circularProgressBar: CircularProgressBar = {
        let circularProgressBar = CircularProgressBar()
        circularProgressBar.labelSize = 10
        circularProgressBar.safePercent = 100
        circularProgressBar.lineWidth = 5
        return circularProgressBar
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        addSubview(circularProgressBar)
        circularProgressBar.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8)
        
        bindRetry()
    }
    
    func bindRetry() {
        self.onTap {
            if self.circularProgressBar.image.image ==  UIImage(named: AssetEnum.ic_refresh.rawValue){
                self.circularProgressBar.label.isHidden = false
                self.actionRetry()
            }
        }
    }
    
    func updateProgress(to progress: Double){
        self.currentProgress = progress
        DispatchQueue.main.async {
            self.circularProgressBar.setProgress(to: progress, withAnimation: true)
        }
    }
    
    private func uploadSuccess(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateProgress(to: 1.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.fadeOut(duration: 1.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            self.updateProgress(to: 0.0)
        }
    }
    
    private func uploadFailed(){
        DispatchQueue.main.async {
            self.circularProgressBar.setRetryView()
        }
    }
    
    private func actionRetry(){
        self.isExecuted = false
        self.updateProgress(to: 0.02)
        if isFromFeed && !isUploadFeed {
            self.param?.post.responseMedias = nil
            postFeedTrigger()
            return
        } else if isFromFeed {
            self.createPost()
            return
        } else if !isUpload {
            post()
            return
        } else {
            self.postCreateStory(media!, product)
            return
        }
    }
    
    @objc
    private func actionStop(){
        network.stopAll()
        fadeOut(duration: 0.5)
        stopUpload()
    }
}

extension UploadProgressView {
    func uploadStory(_ prod: Product?, _ item: KKMediaItem?, callback: ()->()){
        self.latestUploadType = .story
        self.selected = prod
        self.item = item
        fadeIn()
        post()
        callback()
    }
    
    func uploadPost(param : PostFeedParam, callback: ()->()){
        self.latestUploadType = .feed
        self.param = param
        fadeIn()
        postFeedTrigger()
        callback()
    }
    
    private func postFeedTrigger(){
        isFromFeed = true
        isUploadFeed = false
        postFeed()
    }
    
    private func post(){
        guard let item = self.item else {
            self.uploadFailed()
            return
        }
        isUpload = false
        updateProgress(to: 0.01)
        
        if item.type == .photo {
            uploadPhoto()
        } else {
            uploadVideo()
        }
        
    }
    
    private func uploadPhoto() {
        guard let uploader = self.uploader, let item = self.item else {
            self.uploadFailed()
            return
        }
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = item.data, let uiImage = UIImage(data: data), let ext = item.path.split(separator: ".").last else {
                self.uploadFailed()
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "\(ext)")
            uploader.upload(request: request) { [weak self] (result) in
                switch result{
                case .success(let response):
                    let media = ResponseMedia(
                        id: nil,
                        type: "image",
                        url: response.tmpUrl,
                        thumbnail: Thumbnail(large: response.url, medium: response.url, small: response.url),
                        metadata: Metadata(
                            width: "\(uiImage.size.width * uiImage.scale)",
                            height: "\(uiImage.size.height * uiImage.scale)",
                            size: "0"
                        )
                    )
                    self?.postStory(media)
                    return
                    
                case .failure(let error):
                    self?.handleError(error)
                    return
                }
            }
        } else {
            self.uploadFailed()
            return
        }
    }
    
    private func uploadVideo() {
        uploadVideoStoryThumbnail { [weak self] (thumbnail, metadata) in
            self?.uploadVideoStoryData(mediaCallback: { [weak self] (video) in
                let media = ResponseMedia(
                    id: nil,
                    type: "video",
                    url: video.tmpUrl,
                    thumbnail: thumbnail,
                    metadata: metadata,
                    vodFileId: video.vod?.id,
                    vodUrl: video.vod?.url
                )
                
                self?.postStory(media)
            })
        }
    }
    
    private func uploadVideoStoryThumbnail(mediaCallback: @escaping (Thumbnail, Metadata)->()){
        
        guard let uploader = self.uploader, let item = self.item else {
            self.uploadFailed()
            return
        }
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = item.videoThumbnail?.pngData(), let image = item.videoThumbnail else {
                self.uploadFailed()
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "jpeg")
            uploader.upload(request: request) { [weak self] (result) in
                
                guard let self = self else { return }
                
                switch result{
                case .success(let response):
                    let thumbnail = Thumbnail(
                        large: response.tmpUrl,
                        medium: response.url,
                        small: response.url
                    )
                    
                    let metadata = Metadata(
                        width: "\(image.size.width * image.scale)",
                        height: "\(image.size.height * image.scale)",
                        size: "0"
                    )
                    
                    mediaCallback(thumbnail, metadata)
                    return
                    
                case .failure(let error):
                    self.handleError(error)
                    return
                }
                
            }
            
        } else {
            self.uploadFailed()
            return
        }
    }
    
    private func uploadVideoStoryData(mediaCallback: @escaping (MediaUploaderResult)->()){
        
        guard let uploader = self.uploader, let item = self.item else {
            self.uploadFailed()
            return
        }
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            guard let data = item.data, let ext = item.path.split(separator: ".").last else {
                self.uploadFailed()
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "\(ext)")
            uploader.upload(request: request) { [weak self] (result) in
                
                guard let self = self else { return }
                
                switch(result){
                case .success(let response):
                    mediaCallback(response)
                    return
                    
                case .failure(let error):
                    self.handleError(error)
                    return
                }
                
            }
            
        } else {
            self.uploadFailed()
            return
        }
    }
    
    private func postStory(_ media: ResponseMedia) {
        isUpload = true
        self.media = media
        self.product = [MediaPostProductId(id: self.selected?.id ?? "")]
        self.postCreateStory(media, product)
    }
    
    func postCreateStory(_ media: ResponseMedia, _ product: [MediaPostProductId]?){
        let param = MediaPostStory(medias: [media], postProducts: product)
        let validParameter = ParameterPostStory(post: [param], typePost: "story")
        network.createStory(.createStory, validParameter) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(_):
                self.uploadFailed()
            case .success:
                self.uploadSuccess()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.actionFinishUpload()
                }
            }
        }
        
    }
    
    func postFeed() {
        DispatchQueue.global(qos: .background).async {
            guard let medias = self.param?.post.itemMedias else { return }
            self.uploadLoop(medias: medias) { [weak self] in
                guard let self = self else { return }
                self.isUploadFeed = true
                self.createPost()
            }
        }
    }
    
    func createPost(){
        self.updateProgress(to: 0.99)
        guard let param = self.param else { return self.uploadFailed() }
        network.postSocialNew(.postSocial, param) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(_):
                self.uploadFailed()
            case .success:
                self.uploadSuccess()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.actionFinishUpload()
                }
            }
        }
    }
    
    
    func uploadLoop(medias : [KKMediaItem], endLoop : @escaping ()->()){
        var currentProgress = self.currentProgress
        let valuePerPost = 1 / Double(medias.count)
        let range = 0.99 - 0.02
        self.updateProgress(to: 0.02)
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).sync {
            for item in medias {
                switch item.type {
                case .photo:
                    self.uploadPhotoFeed(image: item) { [weak self] media in
                        guard let self = self else { return }
                        if self.param?.post.responseMedias == nil {
                            self.param?.post.responseMedias = [media]
                        } else {
                            self.param?.post.responseMedias?.append(media)
                        }
                        currentProgress = self.currentProgress
                        semaphore.signal()
                    } uploadProgress: { [weak self] (progress) in
                        guard let self = self else { return }
                        let itemProgress = progress * valuePerPost * range
                        let newProgress = currentProgress + itemProgress
                        self.updateProgress(to:  newProgress)
                    }
                case .video:
                    self.uploadVideoFeed(video: item) { [weak self] (media) in
                        guard let self = self else { return }
                        if self.param?.post.responseMedias == nil {
                            self.param?.post.responseMedias = [media]
                        } else {
                            self.param?.post.responseMedias?.append(media)
                        }
                        currentProgress = self.currentProgress
                        semaphore.signal()
                    } uploadProgress: { [weak self] (progress) in
                        guard let self = self  else { return }
                        let itemProgress = progress * valuePerPost * range
                        let newProgress = currentProgress + itemProgress
                        self.updateProgress(to:  newProgress)
                    }
                }
                semaphore.wait()
            }
            if medias.count == self.param?.post.responseMedias?.count && self.param?.post.responseMedias?.count != 0 {
                endLoop()
                return
            }
        }
        
        
        
    }
    
    private func uploadPhotoFeed(image: KKMediaItem, mediaCallback: @escaping (ResponseMedia)->(), uploadProgress: @escaping(Double) -> Void) {
        
        guard let uploader = self.uploader else {
            self.uploadFailed()
            return
        }
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = image.data, let uiImage = UIImage(data: data), let ext = image.path.split(separator: ".").last else {
                self.uploadFailed()
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "\(ext)")
            uploader.upload(request: request) { [weak self] (result) in
                guard let self = self else { return }
                switch result{
                case .success(let response):
                    let media = ResponseMedia(
                        id: nil,
                        type: "image",
                        url: response.tmpUrl,
                        thumbnail: Thumbnail(large: response.url, medium: response.url, small: response.url),
                        metadata: Metadata(
                            width: "\(uiImage.size.width * uiImage.scale)",
                            height: "\(uiImage.size.height * uiImage.scale)",
                            size: "0"
                        )
                    )
                    mediaCallback(media)
                    return
                    
                case .failure(let error):
                    self.handleError(error)
                    return
                }
            } uploadProgress: { [weak self] (percent) in
                guard self != nil else { return }
                uploadProgress(percent)
            }
        } else {
            self.uploadFailed()
            return
        }
    }
    
    private func uploadVideoFeed(video: KKMediaItem, mediaCallback: @escaping (ResponseMedia)->(), uploadProgress: @escaping(Double) -> Void) {
        uploadVideoFeedThumbnail(
            thumbnail: video.videoThumbnail,
            mediaCallback: { [weak self] (thumbnail, metadata) in
                guard let self = self else { return }
                self.uploadVideoFeedData(
                    video: video,
                    mediaCallback: { [weak self] (video) in
                        
                        guard self != nil else { return }
                        let media = ResponseMedia(
                            id: nil,
                            type: "video",
                            url: video.tmpUrl,
                            thumbnail: thumbnail,
                            metadata: metadata,
                            vodFileId: video.vod?.id,
                            vodUrl: video.vod?.url
                        )
                        mediaCallback(media)
                        
                    },
                    uploadProgress: uploadProgress
                )
                
            },
            uploadProgress: uploadProgress
        )
        
    }
    
    private func uploadVideoFeedThumbnail(thumbnail: UIImage?, mediaCallback: @escaping (Thumbnail, Metadata)->(), uploadProgress: @escaping(Double) -> Void){
        
        guard let uploader = self.uploader else {
            self.uploadFailed()
            return
        }
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = thumbnail?.pngData(), let image = thumbnail else {
                self.uploadFailed()
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "jpeg")
            uploader.upload(request: request) { [weak self] (result) in
                
                guard let self = self else { return }
                
                switch result{
                case .success(let response):
                    let thumbnail = Thumbnail(
                        large: response.tmpUrl,
                        medium: response.url,
                        small: response.url
                    )
                    
                    let metadata = Metadata(
                        width: "\(image.size.width * image.scale)",
                        height: "\(image.size.height * image.scale)",
                        size: "0"
                    )
                    
                    mediaCallback(thumbnail, metadata)
                    return
                    
                case .failure(let error):
                    self.handleError(error)
                    return
                }
                
            } uploadProgress: { [weak self] (percent) in
                guard self != nil else { return }
                let p = percent * 0.2
                print("**@@ UploadProgressView thumbnail percent : \(percent) # all process percent = \(p)")
                uploadProgress(p)
            }
            
        }else{
            self.uploadFailed()
            return
        }
    }
    
    private func uploadVideoFeedData(video: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->(), uploadProgress: @escaping(Double) -> Void){
        
        guard let uploader = self.uploader else {
            self.uploadFailed()
            return
        }
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            guard let data = video.data, let ext = video.path.split(separator: ".").last else {
                self.uploadFailed()
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "\(ext)")
            uploader.upload(request: request) { [weak self] (result) in
                
                guard let self = self else { return }
                
                switch(result){
                case .success(let response):
                    mediaCallback(response)
                    return
                    
                case .failure(let error):
                    self.handleError(error)
                    return
                }
                
            } uploadProgress: { [weak self] (percent) in
                guard self != nil else { return }
                let p = (percent * 0.8) + 0.2
                print("**@@ UploadProgressView video percent : \(percent) # all process percent = \(p)")
                uploadProgress(p)
            }
            
        }else{
            self.uploadFailed()
            return
        }
    }
    
    private func handleError(_ error: Error){
        print("**@@ UploadProgressView error \(error.localizedDescription)")
        self.uploadFailed()
    }
}
