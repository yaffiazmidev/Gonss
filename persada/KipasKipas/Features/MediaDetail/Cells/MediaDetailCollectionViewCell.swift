//
//  MediaDetailCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 13/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import VersaPlayer
import AVFoundation

class MediaDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var sliderBarView: UISlider!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var smallPlayPauseButton: UIButton!
    @IBOutlet weak var controlMediaStackView: UIStackView!
    @IBOutlet weak var largePlayPauseButton: UIButton!
    
    var playerLayerAlpha = VersaPlayerView()
    var videoUrl: String?
    var isVideoEnded = false
    var media: Medias?
    var isVideo = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sliderBarView.addTarget(self, action: #selector(onSliderValChanged(slider:event:)),
                                 for: .valueChanged)
    }
    
    func handleOnTapPlayerView() {
        videoPlayerView.isHidden = false
        if isVideoEnded {
            let time = CMTime(seconds: 0.0, preferredTimescale: .max)
            playerLayerAlpha.player.seek(to: time)
            play()
            return
        }
        playerLayerAlpha.isPlaying ? pause() : play()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.isHidden = false
        timeRemainingLabel.text = "00:00"
        isVideo = false
        media = nil
    }
    
    func setupView(media: Medias) {
        self.media = media
        isVideo = media.type != "image"
        
        controlMediaStackView.isHidden = !isVideo
//        largePlayPauseButton.isHidden = !isVideo
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began: pause()
            case .moved: break
            case .ended:
                playbackSliderValueChanged(slider)
                play()
            default: break
            }
        }
    }
    
    func playbackSliderValueChanged(_ sender: UISlider) {
        guard let duration = playerLayerAlpha.player?.currentItem?.duration else { return }
        guard !(duration.seconds.isNaN || duration.seconds.isInfinite) else { return }
        let value = Float64(sender.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        playerLayerAlpha.player.seek(to: seekTime)
    }
    
    func setupVideo(url: String) {
        guard let url = URL(string: url) else {
            print("URL is not valid !!!")
            return
        }
        
        let item = VersaPlayerItem(url: url)
        playerLayerAlpha.set(item: item)
        playerLayerAlpha.autoplay = false
        playerLayerAlpha.playbackDelegate = self
        playerLayerAlpha.frame = videoPlayerView.bounds
        setupRatioVideo()
        videoPlayerView.addSubview(self.playerLayerAlpha)
        playerLayerAlpha.pause()
    }
    
    func setupRatioVideo() {
        let width = Double(media?.metadata?.width ?? "550") ?? 550
        let height =  Double(media?.metadata?.height ?? "550") ?? 550
        
        let ratio = height / width
        
        if width >= height {
            playerLayerAlpha.renderingView.playerLayer.videoGravity = .resizeAspect
            thumbnailImageView.contentMode = .scaleAspectFit
        } else {
            if(ratio < 1.5){
                playerLayerAlpha.renderingView.playerLayer.videoGravity = .resizeAspect
                thumbnailImageView.contentMode = .scaleAspectFit
            } else {
                playerLayerAlpha.renderingView.playerLayer.videoGravity = .resizeAspectFill
                thumbnailImageView.contentMode = .scaleAspectFill
            }
        }
        
    }
    
    func play() {
        if isVideo {
            thumbnailImageView.isHidden = true
            videoPlayerView.isHidden = false
        } else {
            thumbnailImageView.isHidden = false
        }
//        largePlayPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        smallPlayPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playerLayerAlpha.play()
//        largePlayPauseButton.isHidden = true
    }
    
    func pause() {
//        largePlayPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        smallPlayPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playerLayerAlpha.pause()
    }
    
    func resetVideo() {
        let time = CMTime(seconds: 0.0, preferredTimescale: .max)
        playerLayerAlpha.player.seek(to: time)
        timeRemainingLabel.text = "00:00"
        pause()
    }
    
    func autoPlayVideo() {
        videoPlayerView.isHidden = false
        play()
    }
    
    @IBAction func didClickSmallPlayPauseButton(_ sender: UIButton) {
        videoPlayerView.isHidden = false
        if isVideoEnded {
            let time = CMTime(seconds: 0.0, preferredTimescale: .max)
            playerLayerAlpha.player.seek(to: time)
            timeRemainingLabel.text = "00:00"
            play()
            return
        }
        playerLayerAlpha.isPlaying ? pause() : play()
    }
}

extension MediaDetailCollectionViewCell: VersaPlayerPlaybackDelegate {
    func timeDidChange(player: VersaPlayer, to time: CMTime) {
        isVideoEnded = false
        let currentTimeInSeconds = CMTimeGetSeconds(player.currentTime())
        let totalTimeInSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime())
        let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds

        let mins = remainingTimeInSeconds / 60
        let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
        let timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), minsStr != "NaN",
              let secsStr = timeformatter.string(from: NSNumber(value: secs)), secsStr != "NaN" else {
            timeRemainingLabel.text = "00:00"
            return
        }
        
        timeRemainingLabel.text = "\(minsStr):\(secsStr)"
        sliderBarView.value = Float(CMTimeGetSeconds(player.currentTime()) / CMTimeGetSeconds(player.currentItem?.duration ?? CMTime()))
    }
    
    func playbackDidEnd(player: VersaPlayer) {
        isVideoEnded = true
        pause()
//        largePlayPauseButton.isHidden = false
    }
}

