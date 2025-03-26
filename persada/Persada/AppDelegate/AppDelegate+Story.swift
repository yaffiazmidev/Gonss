//
//  AppDelegate+StoryUpload.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/06/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared
import KipasKipasStory
import KipasKipasStoryiOS
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import Combine
import IQKeyboardManagerSwift
import KipasKipasCamera

// Variable
let storyVideoMaxDuration: Double = 180

var storyUploadProgress: (() -> Double)?
var storyOnUpload: (() -> Bool?)?
var storyOnError: (() -> Bool?)?

let storyUploadDidStartUploadNotification = Notification.Name(rawValue: "storyUploadDidStartUploadNotification")
let storyUploadDidProgressNotification = Notification.Name(rawValue: "storyUploadDidProgressNotification")
let storyUploadDidFailureNotification = Notification.Name(rawValue: "storyUploadDidFailureNotification")
let storyUploadDidCompleteNotification = Notification.Name(rawValue: "storyUploadDidCompleteNotification")

struct StoryFromFeedParam {
    let url: String
    let type: KKMediaItemType
    let feedId: String
    let username: String

    init(url: String, type: KKMediaItemType, feedId: String, username: String) {
        self.url = url
        self.type = type
        self.feedId = feedId
        self.username = username
    }
}

// Function
/// Create new story by items from camera/library
var createStoryPost: ((_ items: [KKMediaItem]) -> Void)?
/// Create new story by reposting/embed from feed/social post
var createStoryRepost: ((_ items: [KKMediaItem], _ feedId: String, _ username: String) -> Void)?
/// Retry upload story for current item
var retryStoryUpload: (() -> Void)?
/// Show Media Picker for add Story
var showAddStoryFromLibrary: (() -> Void)?
/// Show Add Story from Feed
var showAddStoryFromFeed: ((StoryFromFeedParam) -> Void)?

class StoryProperty {
    let feedId: String?
    let username: String?
    let type: StoryUploadType
    let items: [KKMediaItem]
    var uploadProgress: Double
    var onUpload: Bool
    var onError: Bool
    
    init(feedId: String? = nil, username: String? = nil, type: StoryUploadType, items: [KKMediaItem], uploadProgress: Double = 0, onUpload: Bool = false, onError: Bool = false) {
        self.feedId = feedId
        self.username = username
        self.type = type
        self.items = items
        self.uploadProgress = uploadProgress
        self.onUpload = onUpload
        self.onError = onError
    }
}

extension AppDelegate {
    func configureStoryFeature() {
        KipasKipas.createStoryPost = createStoryPost
        KipasKipas.createStoryRepost = createStoryRepost
        KipasKipas.storyUploadProgress = storyUploadProgress
        KipasKipas.storyOnUpload = storyOnUpload
        KipasKipas.storyOnError = storyOnError
        KipasKipas.retryStoryUpload = retryStoryUpload
        KipasKipas.showAddStoryFromLibrary = showAddStoryFromLibrary
        KipasKipas.showAddStoryFromFeed = showAddStoryFromFeed
    }
}

// MARK: - Shared
extension AppDelegate {
    func createStoryPost(items: [KKMediaItem]) {
        storyProperties.append(StoryProperty(type: .post, items: items))
        checkUpload()
        sendStartUpload()
        sendProgress()
    }
    
    func createStoryRepost(items: [KKMediaItem], feedId: String, username: String) {
        storyProperties.append(StoryProperty(feedId: feedId, username: username, type: .repost, items: items))
        checkUpload()
        sendStartUpload()
        sendProgress()
    }
    
    func storyUploadProgress() -> Double {
        if storyProperties.isEmpty {
            return 0
        }
        let props = storyProperties
        var p: Double = 0
        props.forEach({ i in
            p = p + i.uploadProgress
        })
        p = p / Double(props.count)
        
        return p
    }
    
    func storyOnUpload() -> Bool {
        storyProperties.contains(where: {$0.onUpload})
    }
    
    func storyOnError() -> Bool {
        storyProperties.contains(where: {$0.onError})
    }
    
    func retryStoryUpload() {
        storyProperties.first?.onUpload = false
        storyProperties.first?.onError = false
        checkUpload()
        sendStartUpload()
    }
    
    func showAddStoryFromLibrary() {
        guard let c = window?.topViewController else { return }
        
        Task {
            let status = await MediaLibraryFetcher.getAuthorizationStatus()
            
            if status == .authorized {
                let picker = KKMediaPicker()
                picker.postType = .story
                picker.useCallbackKKMedia = false
                picker.delegate = self
                picker.videoMaxDuration = storyVideoMaxDuration
                picker.show(in: c)
            } else {
                let settings = UIAlertAction(
                    title: "Pengaturan",
                    style: .default,
                    handler: { _ in UIViewController.openSettings() }
                )
                settings.titleTextColor = .night
                
                let cancel = UIAlertAction(title: "Batal", style: .destructive)
                
                window?.topViewController?.showAlertController(
                    title: "Akses galeri tidak diizinkan",
                    titleFont: .roboto(.bold, size: 18),
                    message: "\nUntuk mengakses foto/video di galeri kamu, akses galeri harus diizinkan. \n\nKamu bisa mengubah izin akses galeri di pengaturan.\n",
                    messageFont: .roboto(.regular, size: 14),
                    backgroundColor: .white,
                    actions: [settings, cancel]
                )
            }
        }
    }
    
    func showAddStoryFromFeed(_ param: StoryFromFeedParam) {
        guard let c = window?.topViewController else { return }

        let controller = StoryPrePostViewController(
            profilePhoto: URL(string: getPhotoURL())
        )

        var editorController: StoryEditorViewController

        if param.type == .photo {
            let editor = StoryPhotoEditorViewController()
            editor.photoURL = URL(string: param.url)
            editorController = editor
        } else {
            let editor = StoryVideoEditorViewController()
            editor.videoURL = URL(string: param.url)
            editorController = editor
        }

        editorController.delegate = controller
        controller.info = param
        controller.delegate = self
        controller.editor = editorController
        controller.modalPresentationStyle = .fullScreen

        c.present(controller, animated: false)
    }

    func makeStoryUploader(_ request: StoryUploadRequest) -> StoryUploader {
        let request = StoryEndpoint.upload(request: request).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<StoryUploadResponse>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeListStoryLoader(_ request: StoryListRequest) -> StoryListLoader {
        let request = StoryEndpoint.list(request: request).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<StoryListResponse>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

extension AppDelegate: KKMediaPickerDelegate {
    func didPermissionRejected() {
        guard let c = window?.topViewController else { return }
        KKMediaPicker.showAlertForAskPhotoPermisson(in: c)
    }
    
    func didLoading(isLoading: Bool) {
        if isLoading {
            KKDefaultLoading.shared.show()
        } else {
            KKDefaultLoading.shared.hide()
        }
    }
    
    func didSelectMedia(originalUrl: URL, type: KKMediaItemType) {
        guard let c = window?.topViewController else { return }
        
        let controller = StoryPrePostViewController(
            profilePhoto: URL(string: getPhotoURL())
        )
        
        var editorController: StoryEditorViewController
        
        if type == .photo {
            let editor = StoryPhotoEditorViewController()
            editor.image = UIImage(contentsOfFile: originalUrl.path)
            editorController = editor
        } else {
            let editor = StoryVideoEditorViewController()
            editor.videoURL = originalUrl
            editorController = editor
        }
        
        editorController.delegate = controller
        controller.delegate = self
        controller.editor = editorController
        controller.modalPresentationStyle = .fullScreen
        
        IQKeyboardManager.shared.enableAutoToolbar = false

        c.present(controller, animated: false)
    }
    
    func didError(_ message: String) {
        toast(message)
    }
    
    func videoNeedTrim(url: URL) {
        toast("Maksimal durasi 3 menit")
        // Sementara di disable, gk perlu trim
        //guard let c = window?.topViewController else { return }
        //let cropper = KKVideoTrimmer(videoUrl: url)
        //cropper.useCallbackKKMedia = false
        //cropper.postType = .story
        //cropper.delegate = self
        //cropper.maxDuration = videoMaxDuration
        //cropper.show(in: c)
    }
}

extension AppDelegate: KKVideoTrimmerDelegate {
    func didLoading(_ trimmer: KKVideoTrimmer, isLoading: Bool) {
        if isLoading {
            KKDefaultLoading.shared.show()
        } else {
            KKDefaultLoading.shared.hide()
        }
    }
    
    func didError(_ trimmer: KKVideoTrimmer, message: String) {
        toast(message)
    }
    
    func didSelectMedia(_ trimmer: KKVideoTrimmer, originalUrl: URL, type: KKMediaItemType) {
        didSelectMedia(originalUrl: originalUrl, type: type)
    }
}

extension AppDelegate: StoryPostDelegate {
    func didPostStory(with media: KKMediaItem, info: Any?) {
        window?.topViewController?.dismiss(animated: false)
        if let param = info as? StoryFromFeedParam {
            createStoryRepost(items: [media], feedId: param.feedId, username: param.username)
            return
        }

        createStoryPost(items: [media])
    }
}

fileprivate extension AppDelegate {
    func toast(_ message: String) {
        Toast.share.show(message: message, backgroundColor: .init(hexString: "4A4A4A"), cornerRadius: 8)
    }
}

// MARK: - Upload Logic
fileprivate extension AppDelegate {
    func checkUpload() {
        guard !storyOnUpload(), let prop = storyProperties.first else { return }
        
        prop.onUpload = true
        DispatchQueue.global(qos: .background).async {
            self.uploadLoop(medias: prop.items) { [weak self] medias in
                guard let self = self else { return }
                self.createStory(medias: medias)
            }
        }
    }
    
    func updateProgress(to value: Double) {
        guard let prop = storyProperties.first else { return }
        
        print("StoryFeature: item progress:", value)
        prop.uploadProgress = value
        sendProgress()
    }
    
    func sendStartUpload() {
        print("StoryFeature: start upload")
        NotificationCenter.default.post(name: storyUploadDidStartUploadNotification, object: nil)
    }
    
    func sendProgress() {
        print("StoryFeature: all progress:", storyUploadProgress())
        NotificationCenter.default.post(
            name: storyUploadDidProgressNotification,
            object: nil,
            userInfo: [
                "progress": storyUploadProgress(),
                "onUpload": storyOnUpload()
            ]
        )
    }
    
    func sendFailure(reason: String, line: Int = #line) {
        print("StoryFeature: failure:", reason, line)
        storyProperties.first?.onError = true
        NotificationCenter.default.post(
            name: storyUploadDidFailureNotification,
            object: nil,
            userInfo: [
                "reason": reason
            ]
        )
    }
    
    func sendComplete() {
        print("StoryFeature: complete")
        NotificationCenter.default.post(name: storyUploadDidCompleteNotification, object: nil)
    }
    
    func uploadSuccess() {
        updateProgress(to: 1.0)
        storyProperties.removeFirst()
        
        guard storyProperties.isEmpty else {
            checkUpload()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sendComplete()
        }
    }
    
    func createStory(medias: [ResponseMedia]) {
        guard let prop = storyProperties.first else { return }
        updateProgress(to: 0.99)
        
        var requests: [StoryUploadMediaRequest] = []
        medias.forEach { media in
            requests.append(
                StoryUploadMediaRequest(
                    type: media.type ?? "",
                    url: media.url ?? "",
                    thumbnail: StoryMediaThumbnailItem(
                        large: media.thumbnail?.large ?? "",
                        medium: media.thumbnail?.medium ?? "",
                        small: media.thumbnail?.small ?? ""
                    ),
                    metadata: StoryMediaMetadataItem(
                        width: media.metadata?.width ?? "",
                        height: media.metadata?.height ?? "",
                        size: media.metadata?.size ?? "",
                        duration: media.metadata?.duration
                    ),
                    vodFileId: media.vodFileId ?? ""
                )
            )
        }
        
        storyUploader.upload(.init(feedIdRepost: prop.feedId, usernameRepost: prop.username, storyType: prop.type, medias: requests)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.uploadSuccess()
            case .failure(let error):
                self.sendFailure(reason: error.localizedDescription)
            }
        }
    }
    
    func uploadLoop(medias : [KKMediaItem], completion : @escaping ([ResponseMedia])->()) {
        guard let prop = storyProperties.first else { return }
        
        var currentProgress = prop.uploadProgress
        let valuePerPost = 1 / Double(medias.count)
        let range = 0.99 - 0.02
        updateProgress(to: 0.02)
        let semaphore = DispatchSemaphore(value: 0)
        var responses: [ResponseMedia] = []
        
        DispatchQueue.global(qos: .background).sync {
            for item in medias {
                switch item.type {
                case .photo:
                    self.uploadPhotoFeed(image: item) { [weak self] media in
                        guard self != nil else { return }
                        responses.append(media)
                        currentProgress = prop.uploadProgress
                        semaphore.signal()
                    } uploadProgress: { [weak self] (progress) in
                        guard let self = self else { return }
                        let itemProgress = progress * valuePerPost * range
                        let newProgress = currentProgress + itemProgress
                        self.updateProgress(to:  newProgress)
                    }
                case .video:
                    self.uploadVideoFeed(video: item) { [weak self] (media) in
                        guard self != nil else { return }
                        responses.append(media)
                        currentProgress = prop.uploadProgress
                        semaphore.signal()
                    } uploadProgress: { [weak self] (progress) in
                        guard let self = self  else { return }
                        let itemProgress = progress * valuePerPost * range
                        let newProgress = currentProgress + itemProgress
                        self.updateProgress(to: newProgress)
                    }
                }
                semaphore.wait()
            }
            
            if responses.count == responses.count, !responses.isEmpty {
                completion(responses)
                return
            }
        }
    }
    
    private func uploadPhotoFeed(image: KKMediaItem, mediaCallback: @escaping (ResponseMedia) -> (), uploadProgress: @escaping(Double) -> Void) {
        
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            sendFailure(reason: "No Internet Connection")
            return
        }
        
        guard let data = image.data, let uiImage = UIImage(data: data), let ext = image.path.split(separator: ".").last else {
            sendFailure(reason: "Invalid images")
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "\(ext)")
        mediaUploader.upload(request: request) { [weak self] (result) in
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
                self.sendFailure(reason: error.localizedDescription)
                return
            }
        } uploadProgress: { [weak self] (percent) in
            guard self != nil else { return }
            uploadProgress(percent)
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
        
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            sendFailure(reason: "No Internet Connection")
            return
        }
        
        guard let data = thumbnail?.pngData(), let image = thumbnail else {
            sendFailure(reason: "Invalid video thumbnail")
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "jpeg")
        mediaUploader.upload(request: request) { [weak self] (result) in
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
                self.sendFailure(reason: error.localizedDescription)
                return
            }
        } uploadProgress: { [weak self] (percent) in
            guard self != nil else { return }
            let p = percent * 0.2
            uploadProgress(p)
        }
    }
    
    private func uploadVideoFeedData(video: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->(), uploadProgress: @escaping(Double) -> Void){
        
        
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            sendFailure(reason: "No Internet Connection")
            return
        }
        
        guard let data = video.data, let ext = video.path.split(separator: ".").last else {
            sendFailure(reason: "Invalid video")
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "\(ext)")
        mediaUploader.upload(request: request) { [weak self] (result) in
            guard let self = self else { return }
            switch(result){
            case .success(let response):
                mediaCallback(response)
                return
            case .failure(let error):
                self.sendFailure(reason: error.localizedDescription)
                return
            }
        } uploadProgress: { [weak self] (percent) in
            guard self != nil else { return }
            let p = (percent * 0.8) + 0.2
            uploadProgress(p)
        }
    }
}
