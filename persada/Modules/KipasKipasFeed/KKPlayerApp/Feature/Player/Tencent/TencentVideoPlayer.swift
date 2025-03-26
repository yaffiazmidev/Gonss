//
//  TencentVideoPlayer.swift
//  KKPlayerApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 22/06/23.
//

import Foundation
import TXLiteAVSDK_Professional
import JWT

class TencentVideoPlayer: NSObject, VideoPlayer {
    // MARK: Variable of VideoPlayer Protocol
    
    static var instance: VideoPlayer = TencentVideoPlayer()

    var delegate: VideoPlayerDelegate?
    
    lazy var playerView: UIView = {
        let view = UIView()
        return UIView()
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
    
    let LOG_ID = "====TencentVideoPlayer"
    
    let player: TXVodPlayer = TXVodPlayer()
    
    var currentVideoId = ""
    
    var loadedDuration = 0.0
    
    let MIN_BUFFER_MARGIN = 3.0
    
    let LOADED_DURATION_OVERLAP = 0.5
    
    private override init(){
        super.init()
        self.setupPlayer()
        self.createBackgroundObserver()
        TencentVideoPlayerHelper.instance.setupLicense()
    }
    
    func setupPlayer() {
        self.player.isAutoPlay = false
        self.player.loop = false
        self.player.enableHWAcceleration = true
        self.player.vodDelegate = self
        self.player.videoProcessDelegate = self
        self.player.setupVideoWidget(self.playerView, insert: 0)
        
        self.player.config = self.getVideoConfig()
    }
    
    func getVideoConfig() -> TXVodPlayConfig {
//        let vodPlayerConfig : TXVodPlayConfig = TXVodPlayConfig()
//
//        //vodPlayerConfig.playerType = 0
//        //vodPlayerConfig.preferredResolution = 720 * 1280;
//
//        vodPlayerConfig.maxPreloadSize = 1
//        vodPlayerConfig.smoothSwitchBitrate = true
//        vodPlayerConfig.enableRenderProcess = true
//        vodPlayerConfig.mediaType = TX_Enum_MediaType.MEDIA_TYPE_HLS_VOD
//        
//        
//        //vodPlayerConfig.firstStartPlayBufferTime = Int32(MIN_BUFFER_MARGIN*1000) //milliseconds
//        //vodPlayerConfig.nextStartPlayBufferTime = Int32(LOADED_DURATION_OVERLAP*1000) //milliseconds
//        
//        return vodPlayerConfig
        
        let vodPlayerConfig : TXVodPlayConfig = TXVodPlayConfig()
        
        //vodPlayerConfig.playerType = 0
        //vodPlayerConfig.preferredResolution = 720 * 1280;
        
        vodPlayerConfig.maxPreloadSize = 1
        vodPlayerConfig.smoothSwitchBitrate = true
        vodPlayerConfig.enableRenderProcess = true
        vodPlayerConfig.firstStartPlayBufferTime = Int32(MIN_BUFFER_MARGIN * 1000) //milliseconds
        vodPlayerConfig.nextStartPlayBufferTime = Int32(MIN_BUFFER_MARGIN * 1000) //milliseconds
        
        vodPlayerConfig.preferredResolution = 1080 * 1920
        
        return vodPlayerConfig
    }
}

// MARK: Function of VideoPlayer Protocol
extension TencentVideoPlayer {
    func play(file: String?, function: String?, line: Int?) {
        print(LOG_ID, "play", file?.split(separator: "/").last, function, line)
        self.isPaused = false
        playVideoWithValidateVolume()
    }
    
    func play(fromBegining: Bool, file: String?, function: String?, line: Int?) {
        print(LOG_ID, "play fromBegining:", fromBegining, file?.split(separator: "/").last, function, line)
        self.isPaused = false
        playVideoWithValidateVolume(isSeekToZero: fromBegining)
    }
    
    func pause(file: String?, function: String?, line: Int?) {
        print(LOG_ID, "pause", file?.split(separator: "/").last, function, line)
        self.isPaused = true
        player.pause()
    }
    
    func initialize() {
        self.player.stopPlay()
        //        self.playerLayer?.set(item: nil)
        //        self.hasVideoAndAudio = false
        self.isPaused = false
        self.isFailed = false
        self.loadedDuration = 0.0
    }
    
    func set(_ url: String) {
        self.set(url, withDuration: 0)
    }
    
    func set(_ url: String, withDuration: Double) {

        let isEmptyCurrentItem = true
        self.loadedDuration = 0
        
        if( isEmptyCurrentItem || self.isFailed) {
            self.duration = withDuration
            self.initialize()
            
            if url.contains("http"){
                self.player.startVodPlay(url)
            }else {
                self.player.startVodPlay(with: TencentVideoPlayerHelper.instance.buildVideoParam(video: url))
            }
                        
            self.currentVideoUrl = url
            self.currentVideoId = url
            let seconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                let timePlaying = CMTimeGetSeconds(self.player.currentPlaybackTime().toCMTimeSeconds())
                
                if(timePlaying == 0) {
                    self.isBuffering = true
                }
            }
        } else {
            //TODO:
            print(self.getLog(), "INIT IGNORE ", "isEmptyCurrentItem:", isEmptyCurrentItem)
        }
    }
}

// MARK: - VOD Process Delegate
extension TencentVideoPlayer: TXVideoCustomProcessDelegate {
    func onPlayerPixelBuffer(_ pixelBuffer: CVPixelBuffer!) -> Bool {
        if let buffer = pixelBuffer {
            delegate?.videoPixelBuffer(pixelBuffer: pixelBuffer)
            return true
        }
        return false
    }
}

// MARK: - VOD Delegate
extension TencentVideoPlayer: TXVodPlayListener {
    
    func onPlayEvent(_ player: TXVodPlayer!, event EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        setPeriodicTimeObserver()
        //loadedTimeRangeObsever replacement in set function(source from VersaVideoPlayer)
        setLoadedTimeRangeObsever()
        
        //print(self.getLog(), "onPlayEvent", param)
              
        
        
        if let fullDuration = param["EVT_PLAY_DURATION"] as? Double {
            let playableDuration = param["PLAYABLE_DURATION"] as! Double
            let progressDuration = param["EVT_PLAY_PROGRESS"] as! Double
            
            let hasBuffer = KKBufferPlayerApp().hasBuffer(total: fullDuration, playable: playableDuration, progress: progressDuration)
        }
        
//        var totalDuration: Double?
//        let duration = player.duration().toCMTimeSeconds()
//        if duration.isValid && !duration.isNegativeInfinity && !duration.isIndefinite {
//            totalDuration = duration.seconds
//        }
//
//        if let totalDuration = totalDuration {
//            if self.duration != totalDuration {
//                self.duration = totalDuration
//            }
//        }
//
//        self.timePlaying = player.currentPlaybackTime().toCMTimeSeconds()
//
//        if self.timePlaying.seconds >= self.duration {
//            guard self.timePlaying.seconds > 0 && self.duration > 0 else { return }
//            self.delegate?.videoDidEndPlaying(player: self)
//        }
    }
    
    func onNetStatus(_ player: TXVodPlayer!, withParam param: [AnyHashable : Any]!) {
//        print(LOG_ID, "onNetStatus")
        if let width = param["VIDEO_WIDTH"] as? Int {
            print("VIDEO WIDTH", width)
        }
    }
    
    func onPlayer(_ player: TXVodPlayer!, pictureInPictureStateDidChange pipState: TX_VOD_PLAYER_PIP_STATE, withParam param: [AnyHashable : Any]!) {
//        print(LOG_ID, "pictureInPictureStateDidChange")
    }
    
    func onPlayer(_ player: TXVodPlayer!, pictureInPictureErrorDidOccur errorType: TX_VOD_PLAYER_PIP_ERROR_TYPE, withParam param: [AnyHashable : Any]!) {
//        print(LOG_ID, "pictureInPictureErrorDidOccur")
    }
    
    func onPlayer(_ player: TXVodPlayer!, airPlayStateDidChange airPlayState: TX_VOD_PLAYER_AIRPLAY_STATE, withParam param: [AnyHashable : Any]!) {
//        print(LOG_ID, "airPlayStateDidChange")
    }
    
    func onPlayer(_ player: TXVodPlayer!, airPlayErrorDidOccur errorType: TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE, withParam param: [AnyHashable : Any]!) {
//        print(LOG_ID, "airPlayErrorDidOccur")
    }
}

// MARK: - Local Function
extension TencentVideoPlayer {
    func isValidDuration(loadedDuration: Double, timePlaying: Double) -> Bool {
        if(loadedDuration.isNaN || loadedDuration.isInfinite){
            return false
        }
        
        return true
    }
    
    func getLog() -> String{
        let log = self.LOG_ID + " " + self.currentVideoId.suffix(20)
        return log
    }
    
    private func playVideoWithValidateVolume(isSeekToZero: Bool = false) {
        let systemVolume = AVAudioSession.sharedInstance().outputVolume
        player.setAudioPlayoutVolume(Int32(systemVolume*100))
        if(isSeekToZero) {
            player.seek(.zero)
        }
        player.resume()
    }
    
    func setPeriodicTimeObserver(){
        let timePlaying = CMTimeGetSeconds(self.player.currentPlaybackTime().toCMTimeSeconds())
        let itemDuration = CMTimeGetSeconds(self.player.duration().toCMTimeSeconds())
        let isEnd = (itemDuration - self.loadedDuration) < 1 ? true : false
        
        if(((self.loadedDuration - timePlaying) < self.LOADED_DURATION_OVERLAP) && !isEnd && self.loadedDuration != 0) {
            self.isBuffering = true
        } else if((self.loadedDuration - timePlaying) >= self.LOADED_DURATION_OVERLAP) {
            self.isBuffering = false
        }
    }
    
    func setLoadedTimeRangeObsever(){
        let timePlaying = CMTimeGetSeconds(self.player.currentPlaybackTime().toCMTimeSeconds())
        let loadedDurationPlayer = CMTimeGetSeconds(self.player.playableDuration().toCMTimeSeconds())
        let itemDuration = CMTimeGetSeconds(self.player.duration().toCMTimeSeconds())
        
        if(timePlaying > loadedDurationPlayer && timePlaying > self.loadedDuration) {
            self.loadedDuration = timePlaying + loadedDurationPlayer
        } else {
            if(loadedDurationPlayer > self.loadedDuration) {
                self.loadedDuration = loadedDurationPlayer
            }
        }
        
        let isEnd = (itemDuration - self.loadedDuration) < self.LOADED_DURATION_OVERLAP ? true : false
        let isBufferEnough = self.loadedDuration - timePlaying >= self.MIN_BUFFER_MARGIN ? true : false
        
//        print(self.getLog(), "Should START CHECK..TRUE", self.loadedDuration, timePlaying, itemDuration, isEnd, isBufferEnough)
        
        if(!self.isPaused){
            if(isBufferEnough || isEnd){
                //            if((self.hasVideoAndAudio && isBufferEnough) || isEnd){
//                print(self.getLog(), "Should START A..TRUE", self.loadedDuration, timePlaying, itemDuration)
                
                self.playVideoWithValidateVolume()
            } else {
                //                if((self.hasAudio(player: player) && self.hasVideo(player: player)) && isBufferEnough){
                //                    self.hasVideoAndAudio = true
                //
                //                    print(self.getLog(), "Should START B..TRUE", self.loadedDuration, timePlaying, itemDuration)
                //                    self.playVideoWithValidateVolume()
                //                }
                if isBufferEnough {
                    self.playVideoWithValidateVolume()
                }
                
            }
        }
    }
}

// MARK: - Observer for Auto Play & Pause
fileprivate extension TencentVideoPlayer {
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
        print("*** TencentVideoPlayer enter background ", isPaused)
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        play()
        NotificationCenter.default.removeObserver(self)
        createBackgroundObserver()
        print("*** TencentVideoPlayer enter foreground ", isPaused)
    }
}

// MARK: - Local Helper for Float Data Type
fileprivate extension Float {
    func toCMTimeSeconds() -> CMTime {
        return CMTime(seconds: Double(self), preferredTimescale: CMTimeScale(1000))
    }
}
