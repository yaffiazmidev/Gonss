//
//  KKVersaVideoPlayer.swift
//  FeedCleeps
//
//  Created by koanba on 05/05/23.
//

import Foundation
import VersaPlayer
import AVFoundation

class KKVersaVideoPlayer: KKVideoPlayer {
    // MARK: Variable of VideoPlayer Protocol
    
    static var instance: KKVideoPlayer = KKVersaVideoPlayer()
    
    var delegate: KKVideoPlayerDelegate?
    
    lazy var playerView: UIView = {
        let versaPlayerView = VersaPlayerView()
        versaPlayerView.renderingView.playerLayer.videoGravity = .resizeAspect
        return versaPlayerView
    }()
    
    var isPaused: Bool = false
    
    var currentVideoUrl: String = ""
    
    var duration: Double = 0.0
    
    var isBuffering: Bool = false {
        didSet {
            delegate?.videoIsBuffering(newVariableValue: isBuffering)
        }
    }
    
    var isFailed: Bool = false {
        didSet {
            delegate?.videoIsFailed(newVariableValue: isFailed)
        }
    }
    
    var timePlaying: CMTime = CMTime() {
        didSet {
            delegate?.videoDidPlaying(currentTime: timePlaying)
        }
    }
    
    // MARK: Local Variable
    
    let LOG_ID = "====KKVersaVideoPlayer"
    
    // for getting playerview as VersaPlayerView
    var playerLayer: VersaPlayerView? {
        if let view = self.playerView as? VersaPlayerView {
            return view
        }
        return nil
    }
    
    var player: VersaPlayer? {
        if let player = self.playerLayer?.player as? VersaPlayer {
            return player
        }
        return nil
    }
    
    let LOADED_DURATION_OVERLAP = 0.5
    
    var currentVideoId = ""
    
    let MIN_BUFFER_MARGIN = 12.0
    
    var hasVideoAndAudio = false
    
    var lastTimePlaying = -1.0
    
    var isCanReset = false
    
    var loadedDuration = 0.0
    
    var loadedTimeRangeObsever:NSKeyValueObservation?
    
    // MARK: Constructor
    private init(){
        self.playerLayer?.autoplay = false
        self.playerLayer?.playbackDelegate = self
        self.playerLayer?.player.automaticallyWaitsToMinimizeStalling = false
        self.createBackgroundObserver()
    }
    
}

// MARK: Function of VideoPlayer Protocol
extension KKVersaVideoPlayer {
    func play(file: String?, function: String?, line: Int?) {
        print(LOG_ID, "play", file?.split(separator: "/").last, function, line)
        KKVersaVideoPlayer.instance.isPaused = false
        playVideoWithValidateVolume()
    }
    
    func play(fromBegining: Bool, file: String?, function: String?, line: Int?) {
        print(LOG_ID, "play fromBegining:", fromBegining, file?.split(separator: "/").last, function, line)
        KKVersaVideoPlayer.instance.isPaused = false
        playVideoWithValidateVolume(isSeekToZero: fromBegining)
    }
    
    func pause(file: String?, function: String?, line: Int?) {
        print(LOG_ID, "pause", file?.split(separator: "/").last, function, line)
        KKVersaVideoPlayer.instance.isPaused = true
        self.player?.pause()
    }
    
    func initialize() {
        self.playerLayer?.set(item: nil)
        self.hasVideoAndAudio = false
        KKVersaVideoPlayer.instance.isPaused = false
        self.isFailed = false
        self.loadedDuration = 0.0
    }
    
    func set(_ item: AVPlayerItem) {
        self.set(item, withDuration: 0)
    }
    
    func set(_ item: AVPlayerItem, withDuration: Double) {
        let assetUrl: URL? = (item.asset as? AVURLAsset)?.url
        
        TiktokPostMediaViewCell.instance.prevPlaying = TiktokPostMediaViewCell.instance.curPlaying
        
        if let assetUrlString = assetUrl?.absoluteString {
            TiktokPostMediaViewCell.instance.curPlaying = assetUrlString
            //KKResourceLoader.instance.priorityVideoId = assetUrlString
        }
        
        let isDifferentItem = TiktokPostMediaViewCell.instance.curPlaying != TiktokPostMediaViewCell.instance.prevPlaying
        let isEmptyCurrentItem = self.playerLayer?.player.currentItem == nil
        self.loadedDuration = 0
        
        if( isEmptyCurrentItem || isDifferentItem || self.isFailed) {
            self.duration = withDuration
            self.initialize()
            
            self.playerLayer?.set(item: item as? VersaPlayerItem)
            self.playerLayer?.player.currentItem?.preferredForwardBufferDuration = self.MIN_BUFFER_MARGIN
            //self.playerLayer.player.currentItem?.preferredForwardBufferDuration = 10
            
            let assetUrl: URL? = (item.asset as? AVURLAsset)?.url
            
            if let assetUrlString = assetUrl?.absoluteString {
                self.currentVideoUrl = assetUrlString
            }
            
//            KKResourceLoader.instance.priorityVideoId = self.currentVideoUrl
            
            self.currentVideoId = KKVideoId().getId(url: assetUrl)
            
            print(LOG_ID, "setItem..", self.currentVideoId)
            
            
            TiktokPostMediaViewCell.instance.curPlaying = assetUrl?.absoluteString ?? ""
            
            let seconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                let timePlaying = CMTimeGetSeconds(self.playerLayer?.player.currentItem?.currentTime() ?? CMTime())
                if(TiktokPostMediaViewCell.instance.curPlaying == assetUrl?.absoluteString && timePlaying == 0) {
                    self.isBuffering = true
                }
            }
            
            let timeCheck = 1.0
            let interval = CMTime(seconds:timeCheck, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            self.playerLayer?.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
                let timePlaying = CMTimeGetSeconds(time)
                let itemDuration = CMTimeGetSeconds(self.playerLayer?.player.currentItem?.duration ?? .zero)
                let isEnd = (itemDuration - self.loadedDuration) < 1 ? true : false
                
                
                if(((self.loadedDuration - timePlaying) < self.LOADED_DURATION_OVERLAP) && !isEnd && self.loadedDuration != 0) {
                    //KKResourceLoader.instance.priorityVideoId = self.currentVideoUrl
                    self.isBuffering = true
                    //} else if((self.loadedDuration - timePlaying) >= 0.5) {
                } else if((self.loadedDuration - timePlaying) >= self.LOADED_DURATION_OVERLAP) {
                    //KKResourceLoader.instance.priorityVideoId = ""
                    self.isBuffering = false
                    
                }
                
            }
            
            loadedTimeRangeObsever = self.playerLayer?.player.observe(\.currentItem?.loadedTimeRanges) { player, change in
                let timePlaying = CMTimeGetSeconds(self.playerLayer?.player.currentTime() ?? CMTime.zero)
                let timeRange = self.playerLayer?.player.currentItem?.loadedTimeRanges.first?.timeRangeValue
                let loadedDurationPlayer = CMTimeGetSeconds(timeRange?.duration ?? CMTime())
                let itemDuration = CMTimeGetSeconds(self.playerLayer?.player.currentItem?.duration ?? .zero)
                
                if(timePlaying > loadedDurationPlayer && timePlaying > self.loadedDuration) {
                    self.loadedDuration = timePlaying + loadedDurationPlayer
                } else {
                    if(loadedDurationPlayer > self.loadedDuration) {
                        self.loadedDuration = loadedDurationPlayer
                    }
                }
                
//                let isEnd = (itemDuration - self.loadedDuration) < self.LOADED_DURATION_OVERLAP ? true : false
                let isEnd = loadedDurationPlayer >= itemDuration
                let isBufferEnough = self.loadedDuration - timePlaying >= self.MIN_BUFFER_MARGIN ? true : false
                
//                print(self.getLog(), "Should START CHECK..TRUE", self.loadedDuration, timePlaying, itemDuration, isEnd, isBufferEnough)
                
                if(!KKVersaVideoPlayer.instance.isPaused){
//                    if((self.hasVideoAndAudio && isBufferEnough) || isEnd){
//                        print(self.getLog(), "Should START A..TRUE", self.loadedDuration, timePlaying, itemDuration)
//
//                        self.playVideoWithValidateVolume()
//                    } else {
//                        if((self.hasAudio(player: player) && self.hasVideo(player: player)) && isBufferEnough){
//                            self.hasVideoAndAudio = true
//
//                            print(self.getLog(), "Should START B..TRUE", self.loadedDuration, timePlaying, itemDuration)
//                            self.playVideoWithValidateVolume()
//                        }
//
//                    }
                    if(isBufferEnough || isEnd || timePlaying == 0.0){
                        //print(self.getLog(), "Should START A..TRUE", self.loadedDuration, timePlaying, itemDuration)

                        self.playVideoWithValidateVolume()
                        //self.printCodec(item: item)
                    }
                }
            }
        } else {
            print(self.getLog(), "INIT IGNORE ", "isDifferentItem:", isDifferentItem, "isEmptyCurrentItem:", isEmptyCurrentItem)
            //self.playerLayer.player.currentItem == nil
        }
    }
}

// MARK: - Local Function
extension KKVersaVideoPlayer {
    func isValidDuration(loadedDuration: Double, timePlaying: Double) -> Bool {
        if(loadedDuration.isNaN || loadedDuration.isInfinite){
            return false
        }
        
        return true
    }
    
    func getLog() -> String{
        let log = self.LOG_ID + " " + self.currentVideoId
        return log
    }
    
    func hasAudio(player: VersaPlayer) -> Bool {
        return player.currentItem?.tracks.filter({$0.assetTrack?.mediaType == AVMediaType.audio}).count != 0
    }
    
    func hasVideo(player: VersaPlayer) -> Bool {
        return player.currentItem?.tracks.filter({$0.assetTrack?.mediaType == AVMediaType.video}).count != 0
    }
    
    private func playVideoWithValidateVolume(isSeekToZero: Bool = false) {
        guard let player = self.playerLayer?.player else { return }
        let systemVolume = AVAudioSession.sharedInstance().outputVolume
        player.volume = systemVolume
        if(isSeekToZero) {
            player.seek(to: .zero)
        }
        player.playImmediately(atRate: 1.0)
    }
    
    func printCodec(item : AVPlayerItem) {
        for track in item.tracks {
            if let formats = track.assetTrack?.formatDescriptions as? [CMFormatDescription] {
                for format in formats {
                    self.printFourCC(CMFormatDescriptionGetMediaSubType(format))
                }
            }
        }
    }

    func printFourCC(_ fcc: FourCharCode) {
        let bytes: [CChar] = [
            CChar((fcc >> 24) & 0xff),
            CChar((fcc >> 16) & 0xff),
            CChar((fcc >> 8) & 0xff),
            CChar(fcc & 0xff),
            0]

        let result = String(cString: bytes)
        let characterSet = CharacterSet.whitespaces
        let codecValue = result.trimmingCharacters(in: characterSet)

        if(codecValue.lowercased() == "avc1"){
            print(self.getLog(), "codec =", codecValue, "(h.264)")
        }

        if(codecValue.lowercased() == "hvc1"){
            print(self.getLog(), "codec =", codecValue, "(h.265)")
        }

    }
}

// MARK: - Versa Delegate
extension KKVersaVideoPlayer : VersaPlayerPlaybackDelegate {
    func timeDidChange(player: VersaPlayer, to time: CMTime) {
        var totalDuration: Double?
        if let duration = self.playerLayer?.player.currentItem?.duration {
            if duration.isValid && !duration.isNegativeInfinity && !duration.isIndefinite {
                totalDuration = duration.seconds
            }
        }
        
        if let totalDuration = totalDuration {
            if self.duration != totalDuration {
                self.duration = totalDuration
            }
        }
        
        self.timePlaying = time
    }
    
    func playbackShouldBegin(player: VersaPlayer) -> Bool {
        return true
    }
    
    func playbackReady(player: VersaPlayer) {
        //print(self.getLog(), "playbackReady")
    }
    
    func playbackDidFailed(with error: VersaPlayerPlaybackError) {
        print(self.getLog(), "playbackDidFailed", "error:", error)
        self.isFailed = true
    }
    
    func playbackWillBegin(player: VersaPlayer) {
        //print(self.getLog(), "playbackWillBegin")
    }
    
    func playbackItemReady(player: VersaPlayer, item: VersaPlayerItem?) {
        print(self.getLog(), "playbackItemReady")
        if(!KKVersaVideoPlayer.instance.isPaused){
            playVideoWithValidateVolume()
        }
    }
    
    func startBuffering(player: VersaPlayer) {
        //print(self.getLog(), "startBuffering")
    }
    
    func endBuffering(player: VersaPlayer) {
        //print(self.getLog(), "endBuffering A")
    }
    
    func playbackDidEnd(player: VersaPlayer) {
        KKVersaVideoPlayer.instance.isPaused = true
        delegate?.videoDidEndPlaying(player: self)
    }
}

// MARK: - Observer for Auto Play & Pause
fileprivate extension KKVersaVideoPlayer {
    func createForegroundObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
    }
    
    func createBackgroundObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        pause()
        NotificationCenter.default.removeObserver(self)
        createForegroundObserver()
        print("*** KKVersaVideoPlayer enter background ", isPaused)
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
//        play()
        NotificationCenter.default.removeObserver(self)
        createBackgroundObserver()
        print("*** KKVersaVideoPlayer enter foreground ", isPaused)
    }
}
