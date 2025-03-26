//
//  PlayerCollectionViewCell.swift
//  KKPlayerApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/06/23.
//

import UIKit
import AVFoundation
import VersaPlayer

class PlayerCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var bufferIndicator: UIActivityIndicatorView!
    
    var videoUrl: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.containerView.removeAllSubviews()
    }
    
    func configure(_ videoUrl: String){
        self.videoUrl = videoUrl
        self.prepareKKPlayer()
    }
    
    func prepareKKPlayer() {
        if let _ = AppConfig.shared.player as? TencentVideoPlayer {
            print("prepare player for id", self.videoUrl.split(separator: "/").last)
            AppConfig.shared.player.set(videoUrl)
        }else {
            print("prepare player for id", self.videoUrl.split(separator: "/").last)
            let url = URL(string: self.videoUrl)!
            let asset = AVURLAsset(url: url)
            let item = VersaPlayerItem(asset: asset)
            AppConfig.shared.player.set(item)
        }
        
        AppConfig.shared.player.delegate = self
        self.containerView.addSubview(AppConfig.shared.player.playerView)
        AppConfig.shared.player.playerView.fillSuperview()
    }
    
    private func secondsToHoursMinutesSeconds(_ seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

extension PlayerCollectionViewCell: VideoPlayerDelegate {
    func videoIsBuffering(newVariableValue value: Bool) {
        bufferIndicator.isHidden = !value
    }
    
    func videoIsFailed(newVariableValue value: Bool) {
        if(value){
            print("Failed playing", self.videoUrl.split(separator: "/").last)
            self.prepareKKPlayer()
        }
    }
    
    func videoDidPlaying(currentTime: CMTime) {
        if !bufferIndicator.isHidden {
            bufferIndicator.isHidden = true
        }
        let seekHMS = secondsToHoursMinutesSeconds(Int(currentTime.seconds))
        let totalHMS = secondsToHoursMinutesSeconds(Int(AppConfig.shared.player.duration))
        let text = String(format: "%02d:%02d/%02d:%02d", seekHMS.minutes, seekHMS.seconds, totalHMS.minutes, totalHMS.seconds)
        print("Playing video", text)
    }
    
    func videoDidEndPlaying(player: VideoPlayer) {
        AppConfig.shared.player.play(fromBegining: true)
    }
    
    func videoPixelBuffer(pixelBuffer: CVPixelBuffer) {
        
    }
}
