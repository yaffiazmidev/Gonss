//
//  TiktokPostMediaViewCell.swift
//  KKCleepsApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/05/22.
//

import UIKit
import VersaPlayer
import AVFoundation
import Kingfisher
import NVActivityIndicatorView


protocol ImageZoomDelegate: AnyObject {
    func imageZoomStart()
    func imageZoomEnd()
}

class PauseGestureViews{
    let view: UIView!
    let gesture: UITapGestureRecognizer!
    
    init(view: UIView, gesture: UITapGestureRecognizer) {
        self.view = view
        self.gesture = gesture
    }
}

enum SingleVideoObserver {
    case timeChange(time: CMTime, totalDuration: CMTime)
    case hasEnded
}

class TiktokPostMediaViewCell: UICollectionViewCell {
    weak var delegate: ImageZoomDelegate?
    
    //    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet var layerView: AVPlayerView!
    @IBOutlet var filteredImageView: UIImageView!
    @IBOutlet var playImageView: UIImageView!
    @IBOutlet var playerView: UIView!
    @IBOutlet var temporaryImage: UIImageView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var imgBlur: UIImageView!
    
    private var media: Medias?
    private weak var parent: TiktokPostViewCell?
    private var isImageDragged:Bool = false

    lazy var playerLayerAlpha: VersaPlayerView = {
        if let view = KKVersaVideoPlayer.instance.playerView as? VersaPlayerView {
            return view
        }
        let view = VersaPlayerView()
        view.renderingView.playerLayer.videoGravity = .resizeAspect
        return view
    }()
    
    lazy var globalPlayerView: UIView = { return UIView() }()

    //lazy var playerLayerAlpha = KKVersaVideoPlayer.instance.playerLayer

    var isPlaying = false
    private var mediaName = ""
    var isImage: Bool = false
    
    var watchTime: Double = 0.0
    var tempWatchTime: Double = 0.0
    var videoDuration: Double = 0.0
    var videoId = ""
    
    var prevPlaying = "prevPlay"
    var curPlaying = "curPlay"
    public static let instance = TiktokPostMediaViewCell()
    
    var loaderDelegate = KKResourceLoader.instance
    
    var lastTryPlayDate = Date()
    var retryCheckTracks = 0
    let maxRetryCheckTracks = 50
    //let maxRetryCheckTracks = 1
    
    var isAlreadyPreparePlayer = false
    
    let LOG_ID = "**TPCell "
    
    var isBufferFull = false
    var lastLoadedDuration = 0.0 // somehow loaded can decreased, so we set last known biggest value
    var prevTimePlay = 0.0

    // MARK: ZOOM
    //    private var zoomView: UIView!
    //    private var windowImageView: UIView?
    //    private var initialCenter: CGPoint?
    //    private var startingRect = CGRect.zero
    //    // a property representing the maximum alpha value of the background
    //    private let maxOverlayAlpha: CGFloat = 0.8
    //    // a property representing the minimum alpha value of the background
    //    private let minOverlayAlpha: CGFloat = 0.4
    //    private var originalImageCenter:CGPoint?
    //    private var pinchGesture: UIPinchGestureRecognizer?
    
    var singleVideoObserver: ((SingleVideoObserver) -> Void)?
    var isMp4: ((Bool) -> Void)?
    
    // MARK: - Pause Handler
    //    private var onPause: (() -> Void)!
    //    private var onPlay: (() -> Void)!
    var pauseGestureViews: [PauseGestureViews]!
    
//    let loadingVideo = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .white, padding: 0)
    
    let playerItemVideoOutput = AVPlayerItemVideoOutput()
    lazy var displayLink: CADisplayLink = CADisplayLink(target: self,
                                                        selector: #selector(displayLinkFired(link:)))
    
    
    let MIN_BUFFER_SECOND = 3.0
    //    let MAX_BUFFER_SECOND = 6.0
    
    
    let IS_USE_FILTER = true
    
    let urlImgBlur = "https://koanba-storage-prod.oss-cn-hongkong.aliyuncs.com/img/thumbnail/background-blur.png"
    
    var MARGIN_BUFFER = 0.0
    
    var videoPlayingTime: Double = 0.0
    var isBufferingVideo: ((Bool)-> Void)?
    
    
    var startTime = Date()
    var lastRetry = Date()

    override func awakeFromNib() {
        super.awakeFromNib()
        pauseGestureViews = []
        self.playerLayerAlpha.autoplay = false
        
//        overlayView.addSubview(loadingVideo)
//        loadingVideo.centerInSuperview(size: CGSize(width: 60, height: 60))
        //        let playerFrame = CGRect(x: 0, y: 0, width: self.layerView.frame.width, height: self.layerView.frame.height)
        //        self.playerLayerAlpha.frame = playerFrame
        //        self.layerView.addSubview(self.playerLayerAlpha)
    }
    
    // MARK: - Lifecycles
    override func prepareForReuse() {
        super.prepareForReuse()
        // Prevent set nil while playing
        // If player stay pause too long please check log "play - yes"
        // Check if url has been nil or not
        //        self.playerLayerAlpha.player.replaceCurrentItem(with: nil)
        //self.playerLayerAlpha.set(item: nil)
        //self.playerLayerAlpha.removeAllSubviews()
        self.layerView.removeAllSubviews()
//        self.temporaryImage.isHidden = false
        self.temporaryImage.image = nil
        self.temporaryImage.layer.name = nil
//        self.filteredImageView.isHidden = true
        self.filteredImageView.image = nil
        self.filteredImageView.layer.name = nil
        self.imgStory.image = nil
        self.imgBlur.image = nil
        self.media = nil
        self.parent = nil
    }
    
    deinit {
        self.clean()
    }
    
    func clean() {
        //        self.playerLayerAlpha.set(item: nil)
        //        self.removeGesture()
        self.parent = nil
    }
    
    //MARK: - Tap Handler
    @objc
    func handlePause() {
        if !KKVideoManager.instance.player.isPaused {
            UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseIn) {
                self.playImageView.isHidden = false
            } completion: { [weak self] _ in
                self?.pause()
                //self?.parent?.feedbarController?.pause()
            }
        } else {
            UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseIn) {
                self.playImageView.isHidden = true
            } completion: { [weak self] _ in
                self?.play(isFromPause: true, from: "TPMV 148")
                //self?.parent?.feedbarController?.play()
            }
        }
    }
}

// MARK: - Helper Methods
extension TiktokPostMediaViewCell {
    func setMedia(media: Medias?, parent: TiktokPostViewCell) {
        
        self.media = media
        self.parent = parent
        self.isImage = media?.type == "image"
        
        print("*****debug PV setMedia.vodUrl :", media?.vodUrl)
        
        
        removePinchGesture()
        if isImage {
            setupImage()
            layerView.isHidden = true
            self.imgStory.isHidden = false
            isImageDragged = false
            isPlaying = true
            //            if pinchGesture == nil {
            //                addZoomGesturesToView()
            //            }
        } else {
            if(TiktokPostMediaViewCell.instance.curPlaying != TiktokPostMediaViewCell.instance.prevPlaying) {
                //                setupImageBlur()
                //                setupVideo()
                self.playImageView.isHidden = true
                layerView.isHidden = false
                isImageDragged = true
            }
        }
        
        self.startTime = Date()
    }
    
    func setupGesture(views anyViews: [UIView] = []) {
        self.overlayView.isHidden = false
        self.playImageView.isHidden = true
        pauseGestureViews.append(
            PauseGestureViews(
                view: overlayView,
                gesture: UITapGestureRecognizer(target: self, action: #selector(handlePause))
            )
        )
        for view in anyViews {
            pauseGestureViews.append(
                PauseGestureViews(
                    view: view,
                    gesture: UITapGestureRecognizer(target: self, action: #selector(handlePause))
                )
            )
        }
        for pauseGestureView in pauseGestureViews {
            pauseGestureView.view.addGestureRecognizer(pauseGestureView.gesture)
        }
    }
    
    func removeGesture() {
        self.overlayView.isHidden = true
        for pauseGestureView in pauseGestureViews {
            if let _ = pauseGestureView.view.gestureRecognizers?.contains(pauseGestureView.gesture) {
                pauseGestureView.view.removeGestureRecognizer(pauseGestureView.gesture)
            }
        }
        pauseGestureViews.removeAll()
    }
    
    //    func getMediaURL() -> String {
    //        if let hlsURL = self.media?.hlsUrl {
    //            return hlsURL
    //        }
    //
    //        guard let mp4URL = self.media?.url else { return "" }
    //        return mp4URL
    //    }
    
    func getMediaName() -> String {
        let mediaUrl = getMediaProxyUrl()
        mediaName = getVideoId(urlPath: mediaUrl)
        return mediaName
    }
    
    func getMediaNameMP4() -> String {
        let mediaURL = self.media?.playURL ?? ""
        
        if(mediaURL.lowercased().contains("mp4")){
            return mediaURL
        }

        if(mediaURL.lowercased().contains("m3u8")){
            return mediaURL
        }

        return "NOT-MP4"
    }
    
    func getUserName() -> String {
        return ""
    }
    
    var playableDuration: TimeInterval? {
        
        guard let currentItem = self.playerLayerAlpha.player.currentItem else { return nil }
        guard currentItem.status == .readyToPlay else { return nil }
        
        let timeRangeArray = currentItem.loadedTimeRanges
        
        let currentTime = self.playerLayerAlpha.player.currentTime()
        
        for value in timeRangeArray {
            let timeRange = value.timeRangeValue
            if CMTimeRangeContainsTime(timeRange, time: currentTime) {
                return CMTimeGetSeconds(CMTimeRangeGetEnd(timeRange))
            }
        }
        
        guard let timeRange = timeRangeArray.first?.timeRangeValue else { return 0}
        
        let startTime = CMTimeGetSeconds(timeRange.start)
        let loadedDuration = CMTimeGetSeconds(timeRange.duration)
        return startTime + loadedDuration
    }
    
}

// MARK: - Image Helper
extension TiktokPostMediaViewCell {
    private func setupImage(){
        setupImageBlur()
        let thumbnail = self.media?.url ?? ""
        self.imgStory.loadImage(at: thumbnail, .w720, emptyImageName: .get(.PotraitPlaceholder))
        self.setContentMode()
    }
    
    private func setupImageBlur(){
        let thumbnail = self.media?.thumbnail?.medium ?? ""
//        let thumbnailWithColour = thumbnail + ossBackgroundImageColor
        KKBackgroundMedia.instance.blur(thumbnail, imgView: imgBlur)
        setContentModeBlur()
    }
    
    private func setContentModeBlur() {
        let width = Double(media?.metadata?.width ?? "550") ?? 550
        let height =  Double(media?.metadata?.height ?? "550") ?? 550
        
        let ratio = height / width
        
        self.imgBlur.contentMode = .scaleAspectFill
    }
    
    private func setContentMode() {
        if imgStory.image?.imageOrientation == .up {
            imgStory.contentMode = .scaleAspectFit
        } else if imgStory.image?.imageOrientation == .left || imgStory.image?.imageOrientation == .right {
            imgStory.contentMode = .scaleAspectFill
        }
    }
    
    private func resetImage() {
        UIView.animate(withDuration: 0.3, animations: {
            //                        self.scrollV.zoomScale = 1.0
        }) { [weak self] (isAnimationDone) in
            if isAnimationDone {
                self?.delegate?.imageZoomEnd()
                self?.isImageDragged = false
            }
        }
    }
    
    
}

// MARK: - Video Helper
extension TiktokPostMediaViewCell {
    
    func prepareKKPlayer(withThumbnail: Bool = true, isResetSeek: Bool = false) {
        if !isResetSeek {
            if KKVideoManager.instance.type == .versa {
                let videoId = KKResourceHelper.instance.getVideoId(urlPath: KKResourceLoader.instance.loadingRequest?.request.url?.absoluteString ?? "")
                KKDownloadTask.instance.sessions[videoId]?.task?.cancel()
                KKDownloadTask.instance.sessions[videoId] = nil
            }
        }

        if(!isImage){
            print("*** prepareKKPlayer A: \(self.getMediaNameMP4().suffix(18)) ")
            self.setupImageBlur()
            self.setupRatioVideo()
            
            // return from API problem, twice from source
            let durationMetadata = ( (media?.metadata?.duration ?? 0.0) ) + 1
            
            self.videoDuration = durationMetadata

            KKVideoManager.instance.player.delegate = self
            print("*** prepareKKPlayer B: \(self.getMediaNameMP4().suffix(18)) ")

            if let _ = KKVideoManager.instance.player as? KKTencentVideoPlayer {
                print("**** cel, prepare KKTencentVideoPlayer vodUrl:", self.media?.vodUrl, "url:", self.media?.url)
                //print("**** cel, prepare KKTencentVideoPlayer ", self.media?.vodUrl, self.media?.url)

                KKVideoManager.instance.player.set(self.media?.playURL ?? "", withDuration: durationMetadata)

                self.globalPlayerView.addSubview(KKVideoManager.instance.player.playerView)
                KKVideoManager.instance.player.playerView.fillSuperviewFeedCleeps()
                self.setupRatioFilteredImage()
            }

            if let player = KKVideoManager.instance.player as? KKVersaVideoPlayer{
                var delegateUrl = self.media?.url!.replacingOccurrences(of: "https", with: "kipas-app")
                delegateUrl = delegateUrl?.replacingOccurrences(of: "http", with: "kipas-app")

                let url = URL(string: (delegateUrl)!)!
                
                let asset = AVURLAsset(url: url)
                asset.resourceLoader.setDelegate(self.loaderDelegate, queue: DispatchQueue.main)
                
                //KKResourceLoader.instance.priorityVideoId = delegateUrl ?? ""

                let item = VersaPlayerItem(asset: asset)

                if let view = player.playerLayer {
                    self.playerLayerAlpha = view
                }

                print("cel, prepare KKVersaVideoPlayer ", item)
                
                if(isResetSeek) {
                    let url = (player.player?.currentItem?.asset as? AVURLAsset)?.url
                    if(url != nil) {
                        self.pause()
                        let timePlaying = player.player?.currentTime() ?? .zero
                        let timePlayingSecond = CMTimeGetSeconds(timePlaying)
                        player.playerLayer?.set(item: item)
                        let seekTime = CMTime(value: CMTimeValue(timePlayingSecond + 0.2), timescale: 1)
                        player.player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
                        self.play(isFromPause: true, from: "TPMVC 400")
                    }
                } else {
                    KKVideoManager.instance.player.set(item, withDuration: durationMetadata)
                }
                
                player.playerLayer?.player.currentItem?.add(self.playerItemVideoOutput)
                self.displayLink.add(to: .main, forMode: .common)
            }

            if withThumbnail {
                self.temporaryImage.isHidden = false
                self.filteredImageView.isHidden = true
            }
        }
        else {
            KKVideoManager.instance.player.pause()
        }
    }
    
    func play(isFromPause: Bool, useProxy: Bool = true, from: String){
        self.isPlaying = true
        self.playImageView.isHidden = true
//        self.temporaryImage.isHidden = true
//        self.filteredImageView.isHidden = false
        if !isImage {
            KKVideoManager.instance.player.play()
        }
    }
    
    func hideThumb() {
//        self.temporaryImage.isHidden = true
    }
    
    func pause(){
        self.isPlaying = false
        if !isImage {
            //self.playerLayerAlpha.pause()
            KKVideoManager.instance.player.pause()
        }
    }
    
    func stop(){
        self.isPlaying = false
        self.pause()
        if !isImage {
            //self.playerLayerAlpha.pause()
            KKVideoManager.instance.player.pause()
            //            KKVideoManager.shared.pause(id: self.videoId)
        }
    }
    
    func pauseAndSeek(){
        self.isPlaying = false
        if !isImage {
            //self.playerLayerAlpha.pause()
//            let time = CMTime(seconds: 0.0, preferredTimescale: .max)
//            self.playerLayerAlpha.player.seek(to: time)
        }
    }
    
    func didEndDisplaying(fromComment: Bool = false){
        
        if(!isImage){
            print(self.LOG_ID, "didEndDisplaying currentItem != nil", self.getMediaNameMP4().suffix(18))
            
            if(self.playerLayerAlpha.player.currentItem != nil) {
                if !fromComment {
                    //self.pause()
                }
            }
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.removeObserver(self, name: VersaPlayer.VPlayerNotificationName.timeChanged.notification, object: nil)
            
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime,
                                                      object: self.playerLayerAlpha.player.currentItem)
            
            //self.playerLayerAlpha.playbackDelegate = nil
            
//            self.loadingVideo.stopAnimating()
        }
        
    }
    
    func setupOverlayLayer() {
        let clear = UIColor.clear.cgColor
        let color = UIColor.black.withAlphaComponent(0.25).cgColor
        
        let layer1 = CAGradientLayer()
        layer1.colors = [color, clear, clear, color]
        layer1.locations = [0, 0.12, 0.80, 1]
        layer1.frame = layerView.bounds
        
        playerView.backgroundColor = .clear
        playerView.layer.insertSublayer(layer1, at: 0)
    }
    
    func setupVideo() {
        
        //        if layerView.frame.size != frame.size {
        //            layerView.frame.size = frame.size
        //        }
        
        //if playerLayerAlpha.frame.size != layerView.frame.size {
        //            let playerFrame = CGRect(x: 0, y: 0, width: self.layerView.frame.width, height: self.layerView.frame.height)
        //            playerLayerAlpha.frame = playerFrame
        //}
        
        //        preparePlayer()
        //
        //        if(!isImage && self.getMediaProxyUrl() != ""){
        //            //print("***** TPMV setupVideo", self.getMediaProxyUrl(), play)
        //            let mediaURL = self.getMediaProxyUrl()
        //
        //            if(mediaURL != ""){
        //                self.videoId = self.getMediaProxyUrl()
        //            }
        //        }
    }
        
    func showCover(){
        let thumbnail = self.media?.thumbnail?.large ?? ""
        var thumbnailResize = thumbnail + "?x-oss-process=image/format,jpg/interlace,1/resize,w_"+OSSSizeImage.w720.rawValue
        
//        thumbnailResize += "/bright,8/contrast,11"
        //thumbnailResize += "/bright,15/sharpen,100"
        
        //print("*** thumbnailResize urlMediaPost==", thumbnailResize)

        self.filteredImageView.image = nil
        self.temporaryImage.isHidden = false
        self.temporaryImage.loadImage(at: thumbnailResize, .w720, emptyImageName: .get(.PotraitPlaceholder))
        if let image = self.temporaryImage.image, let ciImage = CIImage(image: image) {
            self.temporaryImage.image = self.addFilter(ciImage, value: 0.5999999995)
        }
//        self.temporaryImage.image = self.addFilter(CIImage(image: self.temporaryImage.image!)!)
        self.temporaryImage.layer.name = self.getMediaNameMP4()
        self.filteredImageView.layer.name = self.getMediaNameMP4()
        self.setupRatioTemporaryImage()
    }
    
    private func setupRatioTemporaryImage() {
        let width = Double(media?.metadata?.width ?? "550") ?? 550
        let height =  Double(media?.metadata?.height ?? "550") ?? 550
        
        let ratio = height / width
        
        if width >= height {
            self.temporaryImage.contentMode = .scaleAspectFit
        } else {
            if(ratio < 1.5){
                self.temporaryImage.contentMode = .scaleAspectFit
            } else {
                self.temporaryImage.contentMode = .scaleAspectFill
            }
        }
        
        self.temporaryImage.fillSuperviewFeedCleeps()
    }
    
    private func setupRatioFilteredImage() {
        let width = Double(media?.metadata?.width ?? "550") ?? 550
        let height =  Double(media?.metadata?.height ?? "550") ?? 550
        
        let ratio = height / width
        
        if width >= height {
            self.filteredImageView.contentMode = .scaleAspectFit
        } else {
            if(ratio < 1.5){
                self.filteredImageView.contentMode = .scaleAspectFit
            } else {
                self.filteredImageView.contentMode = .scaleAspectFill
            }
        }
        
        self.filteredImageView.fillSuperviewFeedCleeps(padding: .zero)
    }
    
    func setupRatioVideo(){
        let width = Double(media?.metadata?.width ?? "550") ?? 550
        let height =  Double(media?.metadata?.height ?? "550") ?? 550
        
        let ratio = height / width
        
        if let url = self.media?.url, url.contains(".mp4") {
            if width >= height {
                self.playerLayerAlpha.renderingView.playerLayer.videoGravity = .resizeAspect
            } else {
                if(ratio < 1.5){
                    self.playerLayerAlpha.renderingView.playerLayer.videoGravity = .resizeAspect
                } else {
                    self.playerLayerAlpha.renderingView.playerLayer.videoGravity = .resizeAspectFill
                }
            }
        }
    }
    
    func getMediaProxyUrl() -> String {
        var result = ""
        let hlsURL = self.media?.hlsUrl
        if(hlsURL != nil && hlsURL != "") {
            let reverseProxyURL = "http://127.0.0.1:8080/" + getVideoId(urlPath: hlsURL!) + "/main.m3u8?x=" + hlsURL! + "&priority=true"
            result = reverseProxyURL
        } else {
            let mp4URL = self.media?.url ?? ""
            result = mp4URL
        }
        return result
    }
    
    private func getVideoId(urlPath: String?) -> String {
        var videoId = ""
        if let urlPath = urlPath {
            if urlPath != "" && urlPath != "null" {
                let pathOfUrl = urlPath.components(separatedBy: "/")
                videoId = pathOfUrl[pathOfUrl.count-2]
            }
        }
        return videoId
    }
    
    @objc func displayLinkFired(link: CADisplayLink) {
        //if(self.playerLayerAlpha.player.currentItem != nil) {
        self.filteredImageView.layer.name = getMediaNameMP4()
        var currentTime = CMTime.zero
        
        if let _ = KKVideoManager.instance.player as? KKVersaVideoPlayer {
            currentTime = self.playerLayerAlpha.player.currentTime()
        }

        if let player = KKVideoManager.instance.player as? KKTencentVideoPlayer {
            currentTime = player.timePlaying
        }

        if currentTime == CMTime.zero {
            self.setupRatioFilteredImage()
            self.isAlreadyPreparePlayer = false
        } else {
            if !self.temporaryImage.isHidden {
//                self.temporaryImage.isHidden = true
            }
            
            if self.filteredImageView.isHidden {
//                self.filteredImageView.isHidden = false
            }
        }
        
        if playerItemVideoOutput.hasNewPixelBuffer(forItemTime: currentTime) {
            if let buffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
                
                applyFilter(buffer)
                
            }
        }
        //}
    }
    
    func applyFilter(_ buffer: CVPixelBuffer) {
        if !self.playImageView.isHidden {
            self.playImageView.isHidden = true
        }
        
        let originalImage = CIImage(cvImageBuffer: buffer)
        
//        let filterOne = CIFilter(name: "CINoiseReduction")!
//        filterOne.setValue(originalImage, forKey: kCIInputImageKey)
//        filterOne.setValue(0.1, forKey:  kCIInputSharpnessKey)
//        let imageOne = filterOne.outputImage!.cropped(to: originalImage.extent)
        
//            let filterTwo = CIFilter(name: "CIExposureAdjust")!
//            filterTwo.setValue(originalImage, forKey: kCIInputImageKey)
//            filterTwo.setValue(0.3, forKey:  kCIInputEVKey )
//            let imageTwo = filterTwo.outputImage!.cropped(to: originalImage.extent)
        
//        let filterTwo = CIFilter(name: "CIGammaAdjust")!
//        filterTwo.setValue(imageOne, forKey: kCIInputImageKey)
//        filterTwo.setValue(1.1, forKey:  "inputPower")
//        let imageTwo = filterTwo.outputImage!.cropped(to: imageOne.extent)

//        let filterOne = CIFilter(name: "CINoiseReduction")!
//        filterOne.setValue(originalImage, forKey: kCIInputImageKey)
//        filterOne.setValue(0.1, forKey:  kCIInputSharpnessKey)
//        let imageOne = filterOne.outputImage!.cropped(to: originalImage.extent)

        
        if temporaryImage.layer.name == filteredImageView.layer.name {
            filteredImageView.isHidden = false
            temporaryImage.isHidden = true
            filteredImageView.image = self.addFilter(originalImage)
        } else {
            filteredImageView.image = nil
            filteredImageView.isHidden = true
        }
    }
    
    func addFilter(_ image: CIImage, value: Double? = nil) -> UIImage {
        let filterTwo = CIFilter(name: "CIExposureAdjust")!
        filterTwo.setValue(image, forKey: kCIInputImageKey)
        //filterTwo.setValue(value ?? 0.3, forKey:  kCIInputEVKey )
        filterTwo.setValue(value ?? 0.0, forKey:  kCIInputEVKey )
        let imageTwo = filterTwo.outputImage!.cropped(to: image.extent)
        
        return UIImage(ciImage: imageTwo)
    }
    
}

extension TiktokPostMediaViewCell: KKVideoPlayerDelegate {
    func videoDidPlaying(currentTime: CMTime) {
        let valueSecond = CMTimeGetSeconds(currentTime)

        guard !(valueSecond.isNaN || valueSecond.isInfinite) else {
            return
        }

        //print("** videoTimePlaying ", self.getMediaNameMP4(), valueSecond, " ~ ",self.videoDuration)
        let metadataTime = CMTime(seconds: Double(self.videoDuration), preferredTimescale: 1)
        var durationTime = CMTime(seconds: KKVideoManager.instance.player.duration, preferredTimescale: 1)
        if !durationTime.isValid || durationTime.isNegativeInfinity || durationTime.isIndefinite {
            durationTime = metadataTime
        }
        filteredImageView.layer.name = getMediaNameMP4()
        UserDefaults.standard.set(filteredImageView.layer.name, forKey: "last_video_play_id")
        singleVideoObserver?(.timeChange(time: currentTime, totalDuration: durationTime))
    }

    func videoDidEndPlaying(player: KKVideoPlayer) {
        singleVideoObserver?(.hasEnded)
    }

    func videoIsBuffering(newVariableValue value: Bool) {
        if(value){
//            self.loadingVideo.startAnimating()
            self.isBufferingVideo?(true)
        } else{
//            self.loadingVideo.stopAnimating()
            self.isBufferingVideo?(false)
        }
    }

    func videoIsFailed(newVariableValue value: Bool) {
        if(value){
            DispatchQueue.main.async {
                print(self.LOG_ID, "wkkk videoIsFailed, re-prepare..", self.getMediaNameMP4().suffix(18))
                self.prepareKKPlayer(withThumbnail: false, isResetSeek: true)
            }
        }

    }
    
    func videoPixelBuffer(pixelBuffer: CVPixelBuffer) {
        DispatchQueue.main.async {
            self.applyFilter(pixelBuffer)
        }
    }
}


// MARK: - Scroll View and Delegate
extension TiktokPostMediaViewCell: UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.imageZoomStart()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isImageDragged = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgStory
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if !isImageDragged {
            resetImage()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        resetImage()
        print(self.LOG_ID, "scrollViewDidEndDragging", self.getMediaNameMP4().suffix(18))
        
    }
}

extension TiktokPostMediaViewCell: UIGestureRecognizerDelegate {
    
    private func addZoomGesturesToView() {
        //        if isImage {
        //            contentView.isUserInteractionEnabled = true
        //
        //            pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        //            pinchGesture?.delegate = self
        //            contentView.addGestureRecognizer(pinchGesture!)
        //            handlePinchEnded()
        //
        //            playImageView.isHidden = true
        //        } else {
        //            imgStory.isHidden = true
        //        }
    }
    
    private func removePinchGesture() {
        //        if let pinchGesture = pinchGesture {
        //            print("KEPANGGIL REMOVE GAGK")
        //            contentView.removeGestureRecognizer(pinchGesture)
        //            self.pinchGesture = nil
        //        }
    }
    
    @objc private func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        if sender.state == .began {
            handlePinchBegan(sender)
        } else if sender.state == .changed {
            handlePinchChange(sender)
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled  {
            handlePinchEnded()
        }
    }
    
    private func handlePinchBegan(_ sender: UIPinchGestureRecognizer) {
        //        print("KEPANGGIL BEGAN GAGK")
        //
        //        handlePause()
        //        let currentScale = self.imgStory.frame.size.width / self.imgStory.bounds.size.width
        //        let newScale = currentScale * sender.scale
        //
        //        if newScale > 1 {
        //            guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {return}
        //
        //            print("media view frame = \(imgStory.frame) \(imgStory.bounds)")
        //
        //            overlayView = UIView.init(
        //                frame: CGRect(
        //                    x: 0,
        //                    y: 0,
        //                    width: (currentWindow.frame.size.width),
        //                    height: (currentWindow.frame.size.height)
        //                )
        //            )
        //
        //            overlayView.backgroundColor = UIColor.black
        //            overlayView.alpha = CGFloat(minOverlayAlpha)
        //            currentWindow.addSubview(overlayView)
        //
        //            initialCenter = sender.location(in: currentWindow)
        //            print("INITIAL CENTER \(String(describing: initialCenter))")
        //
        //            windowImageView = UIImageView.init(image: self.imgStory.image)
        //
        //            print(imgStory.frame)
        //
        //            windowImageView!.contentMode = .scaleAspectFill
        //            windowImageView!.clipsToBounds = true
        //
        //            let point = self.imgStory.convert(
        //                imgStory.frame.origin,
        //                to: nil
        //            )
        //
        //            print("point: \(point)")
        //
        //            startingRect = CGRect(
        //                x: point.x,
        //                y: point.y,
        //                width: imgStory.frame.size.width,
        //                height: imgStory.frame.size.height
        //            )
        //
        //            print("startingRect" + "\(startingRect)")
        //            windowImageView?.frame = startingRect
        //            currentWindow.addSubview(windowImageView!)
        //            currentWindow.bringSubviewToFront(overlayView)
        //            currentWindow.bringSubviewToFront(windowImageView!)
        //            imgStory.isHidden = true
        //        }
    }
    
    private func handlePinchChange(_ sender: UIPinchGestureRecognizer) {
        //        guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
        //              let initialCenter = initialCenter,
        //              let windowImageWidth = windowImageView?.frame.size.width
        //        else { return }
        //
        //        let currentScale = windowImageWidth / startingRect.size.width
        //        let newScale = currentScale * sender.scale
        //        overlayView.alpha = minOverlayAlpha + (newScale - 1) < maxOverlayAlpha ? minOverlayAlpha + (newScale - 1) : maxOverlayAlpha
        //
        //        let pinchCenter = CGPoint(
        //            x: sender.location(in: currentWindow).x - (currentWindow.bounds.midX),
        //            y: sender.location(in: currentWindow).y - (currentWindow.bounds.midY)
        //        )
        //
        //        let centerXDif = initialCenter.x - sender.location(in: currentWindow).x
        //        let centerYDif = initialCenter.y - sender.location(in: currentWindow).y
        //        let zoomScale = (newScale * windowImageWidth >= imgStory.frame.width) ? newScale : currentScale
        //
        //        let transform = currentWindow.transform
        //            .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
        //            .scaledBy(x: zoomScale, y: zoomScale)
        //            .translatedBy(x: -centerXDif, y: -centerYDif)
        //
        //        windowImageView?.transform = transform
        //
        //        sender.scale = 1
    }
    
    private func handlePinchEnded() {
        //        handlePause()
        //        guard let windowImageView = self.windowImageView else { return }
        
        //        UIView.animate(withDuration: 0.3, animations: {
        //            windowImageView.transform = CGAffineTransform.identity
        //            self.imgStory?.transform = CGAffineTransform.identity
        //
        //        }, completion: { [weak self] _ in
        //            guard let self = self else { return }
        //            self.imgStory.isHidden = false
        //            windowImageView.removeFromSuperview()
        //            self.overlayView.removeFromSuperview()
        //            self.playImageView.isHidden = true
        //            print("KEPANGGIL ENDED GAGK")
        //        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
