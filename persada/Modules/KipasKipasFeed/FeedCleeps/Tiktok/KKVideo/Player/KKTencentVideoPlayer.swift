//
//  KKTencentVideoPlayer.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/07/23.
//

import Foundation
import TXLiteAVSDK_Professional

public class KKTencentVideoPlayer: NSObject, KKVideoPlayer {
    // MARK: Variable of VideoPlayer Protocol
    
    public static var instance: KKVideoPlayer = KKTencentVideoPlayer()
    
    public var delegate: KKVideoPlayerDelegate?
    
    lazy public var playerView: UIView = {
        let view = UIView()
        return UIView()
    }()
    
    public var isPaused: Bool = false
    
    public var currentVideoUrl: String = ""
    
    public var duration: Double = 0.0
    
    public var isBuffering: Bool = false {
        didSet {
            delegate?.videoIsBuffering(newVariableValue: isBuffering)
        }
    }
    
    public var isFailed: Bool = false {
        didSet {
            delegate?.videoIsFailed(newVariableValue: isFailed)
        }
    }
    
    public var timePlaying: CMTime = CMTime() {
        didSet {
            delegate?.videoDidPlaying(currentTime: timePlaying)
        }
    }
    
    public var isBufferEnough = false
    
    // MARK: Local Variable
    
    let LOG_ID = "====KKTencentVideoPlayer"
    
    let player: TXVodPlayer = TXVodPlayer()
    
    var currentVideoId = ""
    
    public var loadedDuration = 0.0
    var playDuration = 0.0
    
    let MIN_BUFFER_MARGIN = 3.0
    
    let LOADED_DURATION_OVERLAP = 0.5
    
    
    private override init(){
        super.init()
        self.setupPlayer()
        self.createBackgroundObserver()
        KKTencentVideoPlayerHelper.instance.setupLicense()
    }
    
    func setupPlayer() {        
        self.player.isAutoPlay = false
        self.player.loop = true
        self.player.enableHWAcceleration = true
        self.player.vodDelegate = self
        self.player.videoProcessDelegate = self
        self.player.setupVideoWidget(self.playerView, insert: 0)
        
        self.player.config = self.getVideoConfig()
    }
    
    func getVideoConfig() -> TXVodPlayConfig {
        let vodPlayerConfig : TXVodPlayConfig = TXVodPlayConfig()
        
        //vodPlayerConfig.playerType = 0
        vodPlayerConfig.preferredResolution = KKTencentVideoPlayerHelper.instance.preferredResolution
        
        vodPlayerConfig.maxPreloadSize = 1
        vodPlayerConfig.smoothSwitchBitrate = true
        vodPlayerConfig.enableRenderProcess = true
        vodPlayerConfig.firstStartPlayBufferTime = Int32(MIN_BUFFER_MARGIN * 1000) //milliseconds
        vodPlayerConfig.nextStartPlayBufferTime = Int32(MIN_BUFFER_MARGIN * 1000) //milliseconds
        
        return vodPlayerConfig
    }
}

// MARK: Function of VideoPlayer Protocol
extension KKTencentVideoPlayer {
    public func play(file: String?, function: String?, line: Int?) {
        print(LOG_ID, "play", file?.split(separator: "/").last, function, line)
        self.isPaused = false
        playVideoWithValidateVolume()
    }
    
    public func play(fromBegining: Bool, file: String?, function: String?, line: Int?) {
        print(LOG_ID, "play fromBegining:", fromBegining, file?.split(separator: "/").last, function, line)
        self.isPaused = false
        playVideoWithValidateVolume(isSeekToZero: fromBegining)
    }
    
    public func pause(file: String?, function: String?, line: Int?) {
        print(LOG_ID, "pause", file?.split(separator: "/").last, function, line)
        self.isPaused = true
        player.pause()
    }
    
    public func initialize() {
        self.player.stopPlay()
        //        self.playerLayer?.set(item: nil)
        //        self.hasVideoAndAudio = false
        self.isPaused = false
        self.isFailed = false
        self.loadedDuration = 0.0
    }
    
    public func set(_ url: String) {
        self.set(url, withDuration: 0)
    }
    
    public func set(_ url: String, withDuration: Double) {
        
        TiktokPostMediaViewCell.instance.prevPlaying = TiktokPostMediaViewCell.instance.curPlaying
        TiktokPostMediaViewCell.instance.curPlaying = url
        
        

        
        let isDifferentItem = TiktokPostMediaViewCell.instance.curPlaying != TiktokPostMediaViewCell.instance.prevPlaying
        
        print(self.getLog(), "onPlayEv check:", KKVideoId().getId(urlString: TiktokPostMediaViewCell.instance.curPlaying),
              "isDifferentItem:", isDifferentItem)

        let isEmptyCurrentItem = true
        self.loadedDuration = 0
        
        //if( isEmptyCurrentItem || isDifferentItem || self.isFailed) {
        if( isDifferentItem || self.isFailed) {
            self.duration = withDuration
            self.initialize()
            
            
            isPaused = false
            if url.contains("http"){
                self.player.startVodPlay(url)
            }else {
                self.player.startVodPlay(with: KKTencentVideoPlayerHelper.instance.buildVideoParam(video: url))
            }
            
            self.currentVideoUrl = url
            self.currentVideoId = url
            
            TiktokPostMediaViewCell.instance.curPlaying = url

            self.isBuffering = true
            self.isBufferEnough = false
            self.sendDummyNetStatus()
            
            print(self.getLog(), "isBuffering-C:", self.isBuffering)
            print(self.getLog(), "onPlayEvent setItem")
            
        } else {
            print(self.getLog(), "INIT IGNORE ", "isEmptyCurrentItem:", isEmptyCurrentItem)
        }
    }
}

// MARK: - VOD Process Delegate
extension KKTencentVideoPlayer: TXVideoCustomProcessDelegate {
    public func onPlayerPixelBuffer(_ pixelBuffer: CVPixelBuffer!) -> Bool {
        if let buffer = pixelBuffer {
            delegate?.videoPixelBuffer(pixelBuffer: buffer)
            return true
        }
        return false
    }
}

// MARK: - VOD Delegate
extension KKTencentVideoPlayer: TXVodPlayListener {
    
    public func onPlayEvent(_ player: TXVodPlayer!, event EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        
        print(self.getLog(), "onPlayEvent", EvtID)
        
        if(isPaused){
            print("***** bugpause, isPaused", isPaused)
            player.pause()
            
            return
        }

        if let fullDuration = param["EVT_PLAY_DURATION"] as? Double {
            let playableDuration = param["PLAYABLE_DURATION"] as! Double
            let progressDuration = param["EVT_PLAY_PROGRESS"] as! Double
            self.duration = fullDuration
            self.playDuration = progressDuration
            self.loadedDuration =  playableDuration
        }
        
        self.timePlaying = CMTime(seconds: self.playDuration, preferredTimescale: 1)
        

        let hasBuffer = KKBufferPlayer().hasBuffer(total: self.duration,
                                               playable: self.loadedDuration,
                                               progress: self.playDuration)
        
        if(hasBuffer){
            if(self.isBufferEnough == false){
                self.isBufferEnough = true
                self.sendDummyNetStatus()
                print(self.getLog(), "isBufferEnough-A:", self.isBufferEnough)
            }
        } else {
            if(self.isBufferEnough == true) {
                self.isBufferEnough = false
                self.sendDummyNetStatus()
                print(self.getLog(), "isBufferEnough-B:", self.isBufferEnough)
            }
        }
        
        switch EvtID {
            case 2005, 2019:
                break;
            case 2004, 2014, 2026, 2008, 2003: // 2008: //, 2005:
                self.isBuffering = false
                break
            default:
                self.isBuffering = true
                break
        }

        setPeriodicTimeObserver()

        //loadedTimeRangeObsever replacement in set function(source from KKVersaVideoPlayer)
        setLoadedTimeRangeObsever()
        

        if self.playDuration >= self.duration {
            guard self.playDuration > 0 && self.duration > 0 else { return }
            self.delegate?.videoDidEndPlaying(player: self)
        }
        
    }
    
    public func onNetStatus(_ player: TXVodPlayer!, withParam param: [AnyHashable : Any]!) {
        //        print(LOG_ID, "onNetStatus")
        if let speed = param["NET_SPEED"] as? Int {
            NotificationCenter.default.post(name: Notification.Name("com.koanba.kipaskipas.mobile.NetworkSpeedMonitor.player"), object: ["speed": speed])
        }
    }
    
    public func onPlayer(_ player: TXVodPlayer!, pictureInPictureStateDidChange pipState: TX_VOD_PLAYER_PIP_STATE, withParam param: [AnyHashable : Any]!) {
        //        print(LOG_ID, "pictureInPictureStateDidChange")
    }
    
    public func onPlayer(_ player: TXVodPlayer!, pictureInPictureErrorDidOccur errorType: TX_VOD_PLAYER_PIP_ERROR_TYPE, withParam param: [AnyHashable : Any]!) {
        //        print(LOG_ID, "pictureInPictureErrorDidOccur")
    }
    
    public func onPlayer(_ player: TXVodPlayer!, airPlayStateDidChange airPlayState: TX_VOD_PLAYER_AIRPLAY_STATE, withParam param: [AnyHashable : Any]!) {
        //        print(LOG_ID, "airPlayStateDidChange")
    }
    
    public func onPlayer(_ player: TXVodPlayer!, airPlayErrorDidOccur errorType: TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE, withParam param: [AnyHashable : Any]!) {
        //        print(LOG_ID, "airPlayErrorDidOccur")
    }
    
    func sendDummyNetStatus(){
        NotificationCenter.default.post(name: Notification.Name("com.koanba.kipaskipas.mobile.NetworkSpeedMonitor.player"), object: ["speed": 1000])
    }
}

// MARK: - Local Function
extension KKTencentVideoPlayer {
    
    func isValidDuration(loadedDuration: Double, timePlaying: Double) -> Bool {
        if(loadedDuration.isNaN || loadedDuration.isInfinite){
            return false
        }
        
        return true
    }
    
    func getLog() -> String{
        let log = self.LOG_ID + " " + KKVideoId().getId(urlString: self.currentVideoId)
        return log
    }
    
    private func playVideoWithValidateVolume(isSeekToZero: Bool = false) {
        //let systemVolume = AVAudioSession.sharedInstance().outputVolume
        //player.setAudioPlayoutVolume(Int32(systemVolume*100))
        if(isSeekToZero) {
            player.seek(.zero)
        }
        player.resume()
    }
    
    func setPeriodicTimeObserver(){
        /*
        let timePlaying = CMTimeGetSeconds(self.player.currentPlaybackTime().toCMTimeSeconds())
        let itemDuration = CMTimeGetSeconds(self.player.duration().toCMTimeSeconds())
        let isEnd = (itemDuration - self.loadedDuration) < 1 ? true : false
        
        if(((self.loadedDuration - timePlaying) < self.LOADED_DURATION_OVERLAP) && !isEnd && self.loadedDuration != 0) {
            //self.isBuffering = true
            //} else if((self.loadedDuration - timePlaying) >= 0.5) {
        } else if((self.loadedDuration - timePlaying) >= self.LOADED_DURATION_OVERLAP) {
            //self.isBuffering = false
            
        }
         */
    }
    
    func setLoadedTimeRangeObsever(){
        /*
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
        
        //print(self.getLog(), "Should START CHECK..TRUE", self.loadedDuration, timePlaying, itemDuration, isEnd, isBufferEnough)
        
        if(!self.isPaused){
            if(isBufferEnough || isEnd){
                //            if((self.hasVideoAndAudio && isBufferEnough) || isEnd){
                //print(self.getLog(), "Should START A..TRUE", self.loadedDuration, timePlaying, itemDuration)
                
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
         */
    }
}

// MARK: - Observer for Auto Play & Pause
fileprivate extension KKTencentVideoPlayer {
    func createForegroundObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
    }
    
    func createBackgroundObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        self.pause()
        NotificationCenter.default.removeObserver(self)
        createForegroundObserver()
        print("*** KKTencentVideoPlayer enter background ", isPaused)
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
//        play()
        NotificationCenter.default.removeObserver(self)
        createBackgroundObserver()
        print("*** KKTencentVideoPlayer enter foreground ", isPaused)
    }
}

// MARK: - Local Helper for Float Data Type
fileprivate extension Float {
    func toCMTimeSeconds() -> CMTime {
        return CMTime(seconds: Double(self), preferredTimescale: CMTimeScale(1000))
    }
}
