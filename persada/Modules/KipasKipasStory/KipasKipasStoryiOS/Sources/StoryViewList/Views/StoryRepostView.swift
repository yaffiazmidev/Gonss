import UIKit
import KipasKipasShared
import KipasKipasStory
import KipasKipasImage

final class StoryRepostView: UIView {
    
    private let thumbnailView = UIImageView()
    private var blurView: UIVisualEffectView!
    private let usernameLabel = UILabel()
    
    let playView = StoryPlayView()
    
    var playDuration: TimeInterval {
        return playView.playDuration
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: API
    func configure(with viewModel: StoryItemViewModel) {
        fetchThumbnail(from: viewModel.media.thumbnailURL)
        playView.configure(with: viewModel.media)
        usernameLabel.text = viewModel.repostUsername
    }
    
    func destroy() {
        playView.cleanUp()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playView.center = convert(center, from: self)
        playView.frame.size = resized(size: .init(width: 270, height: 520), basedOn: .height)
    }
    
    private func fetchThumbnail(from url: URL?) {
        fetchImage(
            with: .init(url: url),
            into: thumbnailView
        )
    }
}

// MARK: UI
private extension StoryRepostView {
    func configureUI() {
        configureThumbnailView()
        configurePlayView()
        configureUsernameLabel()
    }
    
    func configureThumbnailView() {
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        
        addSubview(thumbnailView)
        thumbnailView.anchors.edges.pin()
        
        configureBlurView()
    }
    
    func configureBlurView() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        thumbnailView.addSubview(blurView)
        blurView.anchors.edges.pin()
    }
    
    func configurePlayView() {
        playView.layer.cornerRadius = 12
        playView.clipsToBounds = true
        
        addSubview(playView)
    }
    
    func configureUsernameLabel() {
        usernameLabel.font = .roboto(.medium, size: 14)
        usernameLabel.textColor = .white
        
        addSubview(usernameLabel)
        usernameLabel.anchors.leading.spacing(0, to: playView.anchors.leading)
        usernameLabel.anchors.top.spacing(4, to: playView.anchors.bottom)
    }
}
