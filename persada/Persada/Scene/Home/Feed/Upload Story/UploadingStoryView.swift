//
//  ViewLoading.swift
//  custom
//
//  Created by Icon+ Gaenael on 12/04/21.
//

import UIKit
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils

class UploadingStoryView: UIView {
    
    enum UploadType {
        case story
        case feed
    }
    
    var latestUploadType: UploadType = .story
    
    private let downloadManager = DownloadManager()
    private let network = UploadNetworkModel()
    private let uploader: MediaUploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
    private var selected : Product?
    private var item: KKMediaItem?
    
    private var product : [MediaPostProductId] = []
    private var media : ResponseMedia? = nil
    var param : PostFeedParam?
    
    private var isUpload = false
    private var isUploadFeed = false
    private var isFromFeed = false
    private var isExecuted = false
    private var isDone = false
    
    var actionFinishUpload : () -> () = { }
    var stopUpload = { }
    
    override func awakeFromNib() {
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView(){
        alpha = 0
        backgroundColor = UIColor.whiteSnow
        addSubview(horizontal_stack)
        horizontal_stack.addArrangedSubview(lbl_title)
        horizontal_stack.addArrangedSubview(lbl_progress)
        horizontal_stack.addArrangedSubview(vw_progress)
        vw_progress.addSubview(progress)
        horizontal_stack.addArrangedSubview(btn_stop)
        btn_stop.addTarget(self, action: #selector(actionStop), for: .touchUpInside)
        btn_retry.addTarget(self, action: #selector(actionRetry), for: .touchUpInside)
        horizontal_stack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 29, paddingBottom: 8, paddingRight: 29)
        
        NSLayoutConstraint.activate([
            progress.leadingAnchor.constraint(equalTo: vw_progress.leadingAnchor, constant: 0),
            progress.trailingAnchor.constraint(equalTo: vw_progress.trailingAnchor, constant: 0),
            progress.centerYAnchor.constraint(equalTo: vw_progress.centerYAnchor)
        ])
    }
    
    private func uploadSuccess(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.lbl_progress.isHidden = true
            self.vw_progress.isHidden = true
            self.btn_stop.isHidden = true
            self.lbl_title.text = "Upload Berhasil"
            self.lbl_title.textColor = UIColor.success
        }
        
    }
    
    private func uploadFailed(message: String = "Gagal mengupload"){
        DispatchQueue.main.async {
            self.lbl_progress.isHidden = true
            self.vw_progress.isHidden = true
            self.btn_retry.isHidden = false
            self.horizontal_stack.insertArrangedSubview(self.btn_retry, at: 3)
            self.animation(1.0) {
                self.lbl_title.text = message
                self.lbl_title.textColor = UIColor.warning
            } _: {
                
            }
        }
        
        
    }
    
    private func animation(_ duration: CGFloat, _ update: @escaping ()->(), _ completion: @escaping ()->()){
        UIView.animate(withDuration: TimeInterval(duration)) {
            update()
        } completion: { (_) in
            completion()
        }
    }
    
    private let horizontal_stack : UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let lbl_title : UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.text = "Uploading"
        lbl.textColor = .black
        lbl.font = .Roboto(.medium, size: 11)
        lbl.sizeToFit()
        return lbl
    }()
    
    private let lbl_progress : UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.text = "0%"
        lbl.textColor = .black
        lbl.font = .Roboto(.regular, size: 11)
        lbl.sizeToFit()
        return lbl
    }()
    
    private let btn_retry : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "iconUploadRefresh"), for: .normal)
        btn.tintColor = .lightGray
        btn.imageView?.contentMode = .scaleAspectFill
        return btn
    }()
    
    private let btn_stop : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "iconUploadClose"), for: .normal)
        btn.tintColor = .lightGray
        return btn
    }()
    
    private let progress : UIProgressView = {
        let vw = UIProgressView(progressViewStyle: .bar)
        vw.setProgress(0, animated: true)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.trackTintColor = UIColor.lightGray.withAlphaComponent(0.2)
        return vw
    }()
    
    private let vw_progress : UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    @objc private func actionStop(){
        network.stopAll()
        fadeOut(duration: 0.5)
        stopUpload()
    }
    
    @objc private func actionRetry(){
        self.isExecuted = false
        self.horizontal_stack.removeArrangedSubview(self.btn_retry)
        btn_retry.isHidden = true
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
    
}

extension UploadingStoryView {
    
    func uploadStory(_ prod: Product?, _ item: KKMediaItem, callback: ()->()){
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
        lbl_progress.isHidden = false
        vw_progress.isHidden = false
        btn_stop.isHidden = false
        lbl_progress.text = "0%"
        progress.setProgress(0, animated: true)
        lbl_title.text = "Uploading"
        lbl_title.textColor = .black
        isFromFeed = true
        isUploadFeed = false
        
        postFeed()
    }
    
    private func post(){
        guard let item = self.item else { return }
        lbl_progress.isHidden = false
        vw_progress.isHidden = false
        btn_stop.isHidden = false
        lbl_progress.text = "0%"
        progress.setProgress(0, animated: true)
        lbl_title.text = "Uploading"
        lbl_title.textColor = .black
        isUpload = false
        
        switch item.type {
        case .photo: uploadPhoto()
        case .video: uploadVideo()
        }
    }
    
    private func uploadPhoto() {
        guard let item = self.item else {
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
                    
                    self.postStory(media)
                    return
                    
                case .failure(let error):
                    self.uploadFailed(message: error.getErrorMessage())
                    return
                }
                
            } uploadProgress: { [weak self] (percent) in
                guard let self = self else { return }
                
                let percent = percent * 0.8
                DispatchQueue.main.async {
                    self.lbl_progress.text = "\(percent * 100)%"
                    self.progress.setProgress(Float(percent), animated: true)
                }
            }
        } else {
            self.uploadFailed()
            return
        }
    }
    
    private func uploadVideo() {
        uploadVideoThumbnail { [weak self] (thumbnail, metadata) in
            self?.uploadVideoData(mediaCallback: { [weak self] (videoUrl) in
                let media = ResponseMedia(
                    id: nil,
                    type: "video",
                    url: videoUrl,
                    thumbnail: thumbnail,
                    metadata: metadata
                )
                
                self?.postStory(media)
            })
        }
    }
    
    private func uploadVideoThumbnail(mediaCallback: @escaping (Thumbnail, Metadata)->()){
        
        guard let item = self.item else {
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
                    self.uploadFailed(message: error.getErrorMessage())
                    return
                }
                
            } uploadProgress: { [weak self] (percent) in
                guard let self = self else { return }
                
                let percent = percent * 0.1
                DispatchQueue.main.async {
                    self.lbl_progress.text = "\(percent * 100)%"
                    self.progress.setProgress(Float(percent), animated: true)
                }
            }
            
        }else{
            self.uploadFailed()
            return
        }
    }
    
    private func uploadVideoData(mediaCallback: @escaping (String)->()){
        
        guard let item = self.item else {
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
                    mediaCallback(response.tmpUrl)
                    return
                    
                case .failure(let error):
                    self.uploadFailed(message: error.getErrorMessage())
                    return
                }
                
            } uploadProgress: { [weak self] (percent) in
                guard let self = self else { return }
                
                let percent = (percent * 0.7) + 0.1
                DispatchQueue.main.async {
                    self.lbl_progress.text = "\(percent * 100)%"
                    self.progress.setProgress(Float(percent), animated: true)
                }
            }
            
        }else{
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
        network.createStory(.createStory, validParameter) { result in
            switch result {
            case .failure( _):
                self.uploadFailed()
            case .success:
                DispatchQueue.main.async {
                    self.lbl_progress.text = "100%"
                    self.progress.setProgress(1.0, animated: true)
                }
                self.uploadSuccess()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.fadeOut()
                    self.actionFinishUpload()
                }
            }
        }
        
    }
    
    func postFeed() {
        DispatchQueue.global(qos: .background).async {
            guard let medias = self.param?.post.itemMedias else { return }
            self.uploadLoop(medias: medias) {
                DispatchQueue.main.async {
                    self.lbl_progress.text = "80%"
                    self.progress.setProgress(0.8, animated: true)
                }
                self.isUploadFeed = true
                self.createPost()
            }
        }
    }
    
    func createPost(){
        self.updateProgress(text: "90%", progress: 0.9)
        guard let param = self.param else { return self.uploadFailed() }
        network.postSocialNew(.postSocial, param) { result in
            switch result {
            case .failure( _):
                self.uploadFailed()
            case .success:
                DispatchQueue.main.async {
                    self.lbl_progress.text = "100%"
                    self.progress.setProgress(1.0, animated: true)
                }
                self.uploadSuccess()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.fadeOut()
                    self.actionFinishUpload()
                }
            }
        }
    }
    
    func updateProgress(text: String, progress: Float){
        DispatchQueue.main.async {
            self.lbl_progress.text = text
            self.progress.setProgress(progress, animated: true)
        }
    }
    
    
    func uploadLoop(medias : [KKMediaItem], endLoop : @escaping ()->()){
        
        self.updateProgress(text: "0%", progress: 0.0)
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).sync {
            for item in medias {
                switch item.type {
                case .photo:
                    self.uploadPhotoFeed(image: item) { media in
                        if self.param?.post.responseMedias == nil {
                            self.param?.post.responseMedias = [media]
                        } else {
                            self.param?.post.responseMedias?.append(media)
                        }
                        self.updateProgress(text: "\(self.param?.post.responseMedias?.count ?? 0)0%", progress: Float("0.\(self.param?.post.responseMedias?.count ??  0)") ?? 0.0)
                        
                        
                        semaphore.signal()
                    }
                case .video:
                    self.uploadVideoFeed(video: item) { media in
                        if self.param?.post.responseMedias == nil {
                            self.param?.post.responseMedias = [media]
                        } else {
                            self.param?.post.responseMedias?.append(media)
                        }
                        
                        self.updateProgress(text: "\(self.param?.post.responseMedias?.count ?? 0)0%", progress: Float("0.\(self.param?.post.responseMedias?.count ?? 0)") ?? 0.0)
                        
                        semaphore.signal()
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
    
    private func uploadPhotoFeed(image: KKMediaItem, mediaCallback: @escaping (ResponseMedia)->()) {
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = image.data, let uiImage = UIImage(data: data), let ext = image.path.split(separator: ".").last else {
                self.uploadFailed(message: "Failed to Upload")
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
                    self.uploadFailed(message: error.getErrorMessage())
                    return
                }
            }
        } else {
            self.uploadFailed(message: "No Internet Connection")
            return
        }
    }
    
    private func uploadVideoFeed(video: KKMediaItem, mediaCallback: @escaping (ResponseMedia)->()) {
        uploadVideoFeedThumbnail(
            thumbnail: video.videoThumbnail,
            mediaCallback: { [weak self] (thumbnail, metadata) in
                guard let self = self else { return }
                self.uploadVideoFeedData(
                    video: video,
                    mediaCallback: { [weak self] (video) in
                        
                        guard let self = self  else { return }
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
                        let completion = BlockOperation {
                            print("download feeed tiktok ")
                        }
                        
                        if let urlString = media.url, let url = URL(string: urlString) {
                            if self.downloadManager.isFileExists(url: url) {
                                
                            } else {
                                let operation = self.downloadManager.queueDownload(url)
                                completion.addDependency(operation)
                            }
                        }
                        
                        OperationQueue.main.addOperation(completion)
                        return
                    }
                )
                
            }
        )
    }
    
    private func uploadVideoFeedThumbnail(thumbnail: UIImage?, mediaCallback: @escaping (Thumbnail, Metadata)->()){
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = thumbnail?.pngData(), let image = thumbnail else {
                self.uploadFailed(message: "Failed to Upload")
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
                    self.uploadFailed(message: error.getErrorMessage())
                    return
                }
                
            }
        }else{
            self.uploadFailed(message: "No Internet Connection")
            return
        }
    }
    
    private func uploadVideoFeedData(video: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->()){
        if ReachabilityNetwork.isConnectedToNetwork() {
            guard let data = video.data, let ext = video.path.split(separator: ".").last else {
                self.uploadFailed(message: "Failed to Upload")
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
                    self.uploadFailed(message: error.getErrorMessage())
                    return
                }
                
            }
        }else{
            self.uploadFailed(message: "No Internet Connection")
            return
        }
    }
    
}

public extension UIView {
    /**
     Fade in a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeIn(duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
}
