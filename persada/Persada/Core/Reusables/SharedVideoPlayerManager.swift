//
//  VideoPlayerManager.swift
//  KipasKipas
//
//  Created by PT.Koanba on 24/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import ModernAVPlayer
import AVFoundation

final class SharedVideoPlayerManager {
    static let instance = SharedVideoPlayerManager()
    
    var player: ModernAVPlayer!
    
    private init() {
        let config = ModernAVPlayerConfiguration()
        player = ModernAVPlayer(config: config, loggerDomains: [.error, .unavailableCommand])
    }
    
    func load(with playerItem: AVPlayerItem, autostart: Bool = true) {
        let preferredBufferDuration = TimeInterval(4) // seconds
        let preferredBitRate : Double = 1040000 // Bandwidth for RESOLUTION=406x720
        playerItem.preferredForwardBufferDuration = preferredBufferDuration
        playerItem.preferredPeakBitRate = preferredBitRate
        guard let item = ModernAVPlayerMediaItem(item: playerItem, type: .clip, metadata: nil) else { return }
        player.load(media: item, autostart: autostart, position: nil)
        player.loopMode = true
    }
    
    func play() {
        if !isPlaying() {
            player.play()
        }
    }
    
    func pause() {
        if isPlaying() {
            player.pause()
        }
    }
    
    func stop() {
        if isPlaying() {
            player.stop()
        }
    }
    
    func isPlaying() -> Bool {
        if player.player.rate > 0.0 {
           return true
        }
        return false
    }
    
    func togglePlay(){
        if isPlaying() {
            player.pause()
        } else {
            player.play()
        }
    }
}
