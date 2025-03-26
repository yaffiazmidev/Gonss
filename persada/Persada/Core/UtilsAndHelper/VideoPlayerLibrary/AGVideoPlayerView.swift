//
//  VideoPlayerView.swift
//
//  Created by andrii.golovin on 31.07.17.
//  Copyright © 2017 Andrey Golovin. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol AGVideoPlayerViewDelegate {
    func timeChange(_ time: String)
    func videoPlaying()
    func videoPause()
}

extension Notification.Name {
	static let playerDidChangeFullscreenMode = Notification.Name("playerDidEnterFullscreenMode")
}

public class AGVideoPlayerView: UIView {
	
    
    var delegate: AGVideoPlayerViewDelegate?
	//MARK: Public variables
	var videoUrl: URL? {
		didSet {
            print("\(oldValue) + \(videoUrl) + why")
			prepareVideoPlayer()
		}
	}
	
	var previewLowImageUrl: URL?
	var previewImageUrl: URL? {
		didSet {
			previewImageView.loadImage(at: previewImageUrl?.absoluteString ?? "", low: previewLowImageUrl?.absoluteString ?? "")
			previewImageView.isHidden = self.previewImageUrl == nil ? true : false
		}
	}
	
	
	//Automatically play the video when its view is visible on the screen.
	var shouldAutoplay: Bool = false {
		didSet {
			if shouldAutoplay {
				runTimer()
			} else {
				removeTimer()
			}
		}
	}
	
	//Automatically replay video after playback is complete.
	var shouldAutoRepeat: Bool = false {
		didSet {
			if oldValue == shouldAutoRepeat { return }
			if shouldAutoRepeat {
				NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
			} else {
				NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
			}
		}
	}
	
	//Automatically switch to full-screen mode when device orientation did change to landscape.
	var shouldSwitchToFullscreen: Bool = false {
		didSet {
			if oldValue == shouldSwitchToFullscreen { return }
			if shouldSwitchToFullscreen {
				NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
			} else {
				NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
			}
		}
	}
	
	//Use AVPlayer's controls or custom. Now custom control view has only "Play" button. Add additional controls if needed.
	var showsCustomControls: Bool = true {
		didSet {
			playerController.showsPlaybackControls = !showsCustomControls
			customControlsContentView.isHidden = !showsCustomControls
		}
	}
	
	/// The aspect scaling mode of the video, defaults to ResizeAspectFill
	open var videoScalingMode: VideoScalingMode = .resizeAspectFill {
		didSet {
			switch videoScalingMode {
			case .resize:
				playerController.videoGravity = AVLayerVideoGravity(rawValue: convertToAVLayerVideoGravity(AVLayerVideoGravity.resize.rawValue).rawValue)
			case .resizeAspect:
				playerController.videoGravity = AVLayerVideoGravity(rawValue: convertToAVLayerVideoGravity(AVLayerVideoGravity.resizeAspect.rawValue).rawValue)
			case .resizeAspectFill:
				playerController.videoGravity = AVLayerVideoGravity(rawValue: convertToAVLayerVideoGravity(AVLayerVideoGravity.resizeAspectFill.rawValue).rawValue)
			}
		}
	}
	
	//Value from 0.0 to 1.0, which sets the minimum percentage of the video player's view visibility on the screen to start playback.
	var minimumVisibilityValueForStartAutoPlay: CGFloat = 0.9
	
	//Mute the video.
	var isMuted: Bool = false {
		didSet {
			playerController.player?.isMuted = isMuted
		}
	}
	
	func stop(){
		playerController.player?.pause()
        playerController.player?.isMuted = true
        playerController.player = nil
	}
	//MARK: Private variables
	var playerController: AVPlayerViewController = {
		let pc = AVPlayerViewController()
		pc.view.translatesAutoresizingMaskIntoConstraints = false
		pc.showsPlaybackControls = false
		return pc
	}()
	
	fileprivate var isPlaying: Bool = false
	fileprivate var videoAsset: AVURLAsset?
	fileprivate var displayLink: CADisplayLink?
	
	var previewImageView: UIImageView!
	fileprivate var customControlsContentView: UIView!
	fileprivate var playIcon: UIImageView!
	fileprivate var isFullscreen = false
	
	//MARK: Life cycle
	deinit {
		NotificationCenter.default.removeObserver(self)
		removePlayerObservers()
		displayLink?.invalidate()
	}
	
	required override init(frame: CGRect) {
		super.init(frame: frame)
		setUpView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setUpView()
	}
	
	public override func willMove(toWindow newWindow: UIWindow?) {
		super.willMove(toWindow: newWindow)
		if newWindow == nil {
			pause()
			removeTimer()
		} else {
			if shouldAutoplay {
				runTimer()
			}
		}
	}
}

//MARK: View configuration
extension AGVideoPlayerView {
	fileprivate func setUpView() {
		self.backgroundColor = .white
		addVideoPlayerView()
		configurateControls()
	}
	
	private func addVideoPlayerView() {
		playerController.view.frame = self.bounds
		playerController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		playerController.showsPlaybackControls = false
		self.insertSubview(playerController.view, at: 0)
	}
	
	private func configurateControls() {
		customControlsContentView = UIView(frame: self.bounds)
		customControlsContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		customControlsContentView.backgroundColor = .clear
		
		previewImageView = UIImageView(frame: self.bounds)
		previewImageView.backgroundColor = .clear
		previewImageView.contentMode = .scaleAspectFill
		previewImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		previewImageView.clipsToBounds = true
		previewImageView.tintColor = .clear
		
		playIcon = UIImageView(image: UIImage(named: String.get(.iconVideoPlayerPlay)))
        playIcon.isHidden = true
		playIcon.isUserInteractionEnabled = true
		playIcon.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
		playIcon.center = previewImageView!.center
		playIcon.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
		
		addSubview(previewImageView!)
		customControlsContentView?.addSubview(playIcon)
		addSubview(customControlsContentView!)
		let playAction = UITapGestureRecognizer(target: self, action: #selector(didTapPlay))
		playIcon.addGestureRecognizer(playAction)
		let pauseAction = UITapGestureRecognizer(target: self, action: #selector(didTapPause))
		customControlsContentView.addGestureRecognizer(pauseAction)
	}
}

//MARK: Timer part
extension AGVideoPlayerView {
	fileprivate func runTimer() {
		if displayLink != nil {
			displayLink?.isPaused = false
			return
		}
		displayLink = CADisplayLink(target: self, selector: #selector(timerAction))
		if #available(iOS 10.0, *) {
			displayLink?.preferredFramesPerSecond = 5
		} else {
			displayLink?.frameInterval = 5
		}
		displayLink?.add(to: RunLoop.current, forMode: .common)
	}
	
	fileprivate func removeTimer() {
		displayLink?.invalidate()
		displayLink = nil
	}
	
	@objc private func timerAction() {
		guard videoUrl != nil else {
			return
		}
		if isVisible() {
			play()
		} else {
			pause()
		}
	}
}

//MARK: Logic of the view's position search on the app screen.
extension AGVideoPlayerView {
	fileprivate func isVisible() -> Bool {
		if self.window == nil {
			return false
		}
		let displayBounds = UIScreen.main.bounds
		let selfFrame = self.convert(self.bounds, to: UIApplication.shared.windows.map({$0}).first )
		let intersection = displayBounds.intersection(selfFrame)
		let visibility = (intersection.width * intersection.height) / (frame.width * frame.height)
        if playerController.videoBounds.height > UIScreen.main.bounds.height - 100 {
            print("VIDEO BOUNDS \(playerController.videoBounds.height)")
            print("INTERSECTION HEIGHT \(intersection.height)")
            minimumVisibilityValueForStartAutoPlay = 0.5
        }
		return visibility >= minimumVisibilityValueForStartAutoPlay
	}
}

//MARK: Video player part
extension AGVideoPlayerView {
	fileprivate func prepareVideoPlayer() {
		playerController.player?.pause()
		playerController.player?.removeObserver(self, forKeyPath: "rate")
        
		guard let url: URL = videoUrl else {
			videoAsset = nil
			playerController.player = nil
			return
		}
		videoAsset = AVURLAsset(url: url)
		let items = AVPlayerItem(asset: videoAsset!)
        
        playerController.player?.automaticallyWaitsToMinimizeStalling = items.isPlaybackBufferEmpty
        items.preferredForwardBufferDuration = TimeInterval(3)
		let player = AVPlayer(playerItem: items)
		playerController.player = player
		addPlayerObservers()
	}
	
	@objc fileprivate func didTapPlay() {
		displayLink?.isPaused = false
		play()
        delegate?.videoPlaying()
	}
	
	@objc fileprivate func didTapPause() {
		if isPlaying {
			displayLink?.isPaused = true
            delegate?.videoPause()
			pause()
		}else {
			didTapPlay()
		}
	}
	
    func play() {
		if isPlaying { return }
		isPlaying = true
		
		videoAsset?.loadValuesAsynchronously(forKeys: ["playable", "tracks", "duration"], completionHandler: { [weak self]  in
			DispatchQueue.main.async {
				if self?.isPlaying == true {
                    print("YANG PLAY SEKARANG: \(self?.videoUrl) \(self)")
					self?.playIcon.isHidden = true
					self?.previewImageView.isHidden = true
					self?.playerController.player?.play()
				}
			}
		})
	}
	
    func pause() {
		if isPlaying {
			isPlaying = false
			playIcon.isHidden = true
			playerController.player?.pause()
		}
	}
	
	@objc fileprivate func itemDidFinishPlaying() {
		if isPlaying {
			playerController.player?.seek(to: CMTime.zero, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
			playerController.player?.play()
		}
	}
    
    
}

//MARK: Player size observing part
extension AGVideoPlayerView {
	fileprivate func addPlayerObservers() {
		playerController.player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
		playerController.contentOverlayView?.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        
        playerController.player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main) { time in

            if let duration = self.playerController.player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let time = CMTimeGetSeconds(time)
                let newSeconds = seconds-time
                let newtTime = secondsToHoursMinutesSeconds(seconds: Int(newSeconds.isNaN ? 0 : newSeconds))
                let string = String(format: "%2d:%02d", newtTime.1, newtTime.2)
                self.delegate?.timeChange(string)
            }
        }
	}
	
	fileprivate func removePlayerObservers() {
		playerController.player?.removeObserver(self, forKeyPath: "rate")
//		        playerController.contentOverlayView?.removeObserver(self, forKeyPath: "bounds")
	}
	
	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		switch keyPath! {
		case "rate":
			self.previewImageView.isHidden = true
		case "bounds":
			let fullscreen = playerController.contentOverlayView?.bounds == UIScreen.main.bounds
			if isFullscreen != fullscreen {
				isFullscreen = fullscreen
				NotificationCenter.default.post(name: .playerDidChangeFullscreenMode, object: isFullscreen)
			}
		default:
			break
		}
	}
}

//MARK: Device orientation observing
extension AGVideoPlayerView {
	@objc fileprivate func deviceOrientationDidChange(_ notification: Notification) {
		if isFullscreen || !isVisible() { return }
		if let orientation = (notification.object as? UIDevice)?.orientation, orientation == .landscapeLeft || orientation == .landscapeRight {
			playerController.forceFullScreenMode()
			updateDeviceOrientation(with: orientation)
		}
	}
	
	private func updateDeviceOrientation(with orientation: UIDeviceOrientation) {
		UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
			UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
		})
	}
}

//MARK: AVPlayerViewController extension for force fullscreen mode
extension AVPlayerViewController {
	func forceFullScreenMode() {
		let selectorName : String = {
			if #available(iOS 11, *) {
				return "_transitionToFullScreenAnimated:completionHandler:"
			} else {
				return "_transitionToFullScreenViewControllerAnimated:completionHandler:"
			}
		}()
		let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)
		if self.responds(to: selectorToForceFullScreenMode) {
			self.perform(selectorToForceFullScreenMode, with: true, with: nil)
		}
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToAVLayerVideoGravity(_ input: String) -> AVLayerVideoGravity {
	return AVLayerVideoGravity(rawValue: input)
}


/**
Enum for the scaling mode of the video view controller

- Resize:           Resize to fit
- ResizeAspect:     Resize an mantain aspect
- ResizeAspectFill: Resize and fill
*/
public enum VideoScalingMode {
	case resize
	case resizeAspect
	case resizeAspectFill
}
