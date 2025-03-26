import UIKit
import KipasKipasShared
import KipasKipasImage
import KipasKipasStory

enum StoryPlayViewState {
    case ready
    case loading
    case paused
    case resume
    case error
}

enum StoryPlayType {
    case none
    case image
    case video
}

protocol StoryPlayViewDelegate: AnyObject {
    func didChangeState(_ state: StoryPlayViewState)
}

public final class StoryPlayView: UIView {
    
    public static let shouldPausedWhenNotVisible = Notification.Name("StoryPlayView.shouldPausedWhenNotVisible")
    public static let shouldResumeWhenVisible = Notification.Name("StoryPlayView.shouldResumeWhenVisible")
    
    private let imageView = UIImageView()
    private let videoView = VideoPlayerView()
    
    /// Default: 5 seconds for image
    private(set) var playDuration: TimeInterval = 5
    private var playType: StoryPlayType = .none
    
    weak var delegate: StoryPlayViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureLongPressGesture()
        configureNotificationObservers()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(didPressLong(_:))
        )
        longPressGesture.minimumPressDuration = 0.2
        addGestureRecognizer(longPressGesture)
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldPauseWhenNotVisible), name: StoryPlayView.shouldPausedWhenNotVisible, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldResumeWhenVisible), name: StoryPlayView.shouldResumeWhenVisible, object: nil)
    }
    
    @objc private func didPressLong(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            pause()
        } else if gesture.state == .ended {
            resume()
        }
    }
    
    @objc private func shouldPauseWhenNotVisible(_ aNotification: Notification) {
        if playType == .image {
            delegate?.didChangeState(.paused)
        }
    }
    
    @objc private func shouldResumeWhenVisible(_ aNotification: Notification) {
        if playType == .image {
            delegate?.didChangeState(.resume)
        }
    }
    
    // MARK: API
    func setThumbnailImage(from url: URL?) {
        imageView.isHidden = false
        
        fetchImage(with: .init(url: url), into: imageView)
    }
    
    func configure(with viewModel: StoryItemMediaViewModel) {
        switch viewModel.type {
        case .image:
            videoView.isHidden = true
            playType = .image
            delegate?.didChangeState(.loading)
            setImage(from: viewModel.mediaURL)
            
        case .video:
            setThumbnailImage(from: viewModel.thumbnailURL)
            playType = .video
            delegate?.didChangeState(.loading)
            setVideo(from: viewModel.videoURL)
            
        case .none:
            break
        }
    }
    
    func cleanUp() {
        videoView.isHidden = true
        videoView.destroy()
    }
    
    @objc func pause() {
        videoView.pause(reason: .userInteraction)
        delegate?.didChangeState(.paused)
    }
    
    @objc func resume() {
        videoView.resume()
        delegate?.didChangeState(.resume)
    }
}

private extension StoryPlayView {
    func setImage(from url: URL?) {
        imageView.isHidden = false
        playDuration = 5
        
        fetchImage(
            with: .init(url: url),
            into: imageView
        ) { [weak self] image, error in
            if error == nil {
                self?.delegate?.didChangeState(.ready)
            } else {
                self?.delegate?.didChangeState(.error)
            }
        }
    }
    
    func setVideo(from url: URL?) {
        videoView.isHidden = false
        
        guard let url = url else { return }
        
        videoView.playerURL = nil
        videoView.play(for: url)
    }
}

// MARK: UI
private extension StoryPlayView {
    func configureUI() {
        backgroundColor = .night
        clipsToBounds = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configureImageView()
        configureVideoView()
    }
    
    func configureImageView() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        imageView.anchors.edges.pin()
    }
    
    func configureVideoView() {
        videoView.isAutoReplay = false
        videoView.clipsToBounds = true
        videoView.contentMode = .scaleAspectFit
        
        videoView.stateDidChanged = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .loading:
                delegate?.didChangeState(.loading)
            case .playing:
                if videoView.playProgress <= 0.1 {
                    imageView.image = nil
                    playDuration = videoView.totalDuration
                    delegate?.didChangeState(.ready)
                }  else {
                    delegate?.didChangeState(.resume)
                }
            case .pausedOnce:
                delegate?.didChangeState(.paused)
            case .resume:
                delegate?.didChangeState(.resume)
            case let .buffer(playProgress, _):
                if playProgress < 1.0 {
                    delegate?.didChangeState(.paused)
                }
            default:
                break
            }
        }
        
        addSubview(videoView)
        videoView.anchors.edges.pin()
    }
}
