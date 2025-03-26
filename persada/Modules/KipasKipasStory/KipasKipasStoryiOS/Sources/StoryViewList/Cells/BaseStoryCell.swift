import UIKit
import KipasKipasShared
import KipasKipasStory
import KipasKipasImage

protocol StoryCell {
    func resume()
    func pause()
    func cleanUp()
    func resetSegmentedView()
}

internal class BaseStoryCell: UICollectionViewCell, StoryCell {
    
    private let stackContainer = UIStackView()
    private let stackTopView = UIStackView()
    private let infoView = StoryInfoView()

    var segmentedProgressView: SegmentedProgressView?
    
    let playView = StoryPlayView()
    let bottomView = UIView()
    
    private let previousButton = KKBaseButton()
    private let nextButton = KKBaseButton()
    
    private var currentIndex: Int?
    
    var previousButtonCallback: EmptyClosure?
    var nextButtonCallback: EmptyClosure?
    var onReuse: EmptyClosure?
    
    // MARK: Callbacks
    var setViewed: EmptyClosure?
    var onTapLike: Closure<Bool>?
    var onTapCloseButton: EmptyClosure?
    var onTapCamera: EmptyClosure?
    var onTapShareButton: EmptyClosure?
    var onTapListViewers: EmptyClosure?
    var onTapProfile: EmptyClosure?
    
    // MARK: Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }
    
    @objc private func didTapPreviousButton() {
        previousButtonCallback?()
    }
    
    @objc private func didTapNextButton() {
        nextButtonCallback?()
    }
    
    @objc private func didTapCamera() {
        onTapCamera?()
    }
    
    @objc private func didTapClose() {
        onTapCloseButton?()
    }
    
    @objc private func didTapProfile() {
        onTapProfile?()
    }
    
    // MARK: API
    func cleanUp() {
        playView.cleanUp()
        resetSegmentedView()
        setViewed?()
    }
    
    func resetSegmentedView() {
        segmentedProgressView?.pause()
        segmentedProgressView?.removeFromSuperview()
    }
    
    func pause() {
        playView.pause()
    }
    
    func resume() {
        playView.resume()
    }
    
    func configure(with story: StoryItemViewModel, index: Int) {
        previousButton.debounce()
        nextButton.debounce()

        configureSegmentedView()
        
        currentIndex = index
        playView.delegate = self
        playView.configure(with: story.media)
        
        configureInfoView(story)
    }
    
    private func configureInfoView(_ story: StoryItemViewModel) {
        fetchImage(
            with: .init(url: story.account.photoURL, size: .w_100),
            into: infoView.photoView
        )
        infoView.usernameLabel.text = story.account.username
        infoView.timeLabel.text = story.createAtDesc
    }
    
    private func configureSegmentedView() {
        if let segmentedProgressView {
            segmentedProgressView.removeFromSuperview()
            if !stackTopView.contains(segmentedProgressView) {
                stackTopView.insertArrangedSubview(segmentedProgressView, at: 0)
            }
        }
    }
}

extension BaseStoryCell: StoryPlayViewDelegate {
    func didChangeState(_ state: StoryPlayViewState) {
        guard let index = currentIndex else { return }
        
        switch state {
        case .loading:
            segmentedProgressView?.loading(at: index)
        case .ready:
            segmentedProgressView?.play(at: index)
        case .resume:
            segmentedProgressView?.resume()
        case .paused, .error:
            segmentedProgressView?.pause()
        }
    }
}

// MARK: UI
private extension BaseStoryCell {
    func configureUI() {
        configureStackContainer()
        configurePreviewView()
        configureBottomView()
        configureStackTopView()
        configurePreviousButton()
        configureNextButton()
    }
    
    func configureStackContainer() {
        stackContainer.axis = .vertical
        
        addSubview(stackContainer)
        stackContainer.anchors.top.pin(to: safeAreaLayoutGuide)
        stackContainer.anchors.edges.pin(axis: .horizontal)
        stackContainer.anchors.bottom.pin()
    }
    
    func configurePreviewView() {
        playView.backgroundColor = .clear
        playView.layer.cornerRadius = 16
        playView.clipsToBounds = true
            
        stackContainer.addArrangedSubview(playView)
    }
    
    func configureStackTopView() {
        stackTopView.axis = .vertical
        stackTopView.spacing = 14
        
        playView.addSubview(stackTopView)
        stackTopView.anchors.top.pin(inset: 12)
        stackTopView.anchors.edges.pin(insets: 12, axis: .horizontal)
        
        configureInfoContainer()
    }
    
    func configureInfoContainer() {
        infoView.isUserInteractionEnabled = true
        infoView.closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        infoView.storyCameraButton.addTarget(self, action: #selector(didTapCamera), for: .touchUpInside)
        infoView.usernameTapGesture.addTarget(self, action: #selector(didTapProfile))
        infoView.photoTapGesture.addTarget(self, action: #selector(didTapProfile))
        
        stackTopView.addArrangedSubview(infoView)
        infoView.anchors.height.equal(40)
    }
    
    func configureBottomView() {
        bottomView.backgroundColor = .night
        
        stackContainer.addArrangedSubview(bottomView)
        bottomView.anchors.height.equal(94)
    }
    
    func configurePreviousButton() {
        previousButton.backgroundColor = .clear
        previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
        
        playView.addSubview(previousButton)
        previousButton.anchors.leading.pin()
        previousButton.anchors.top.pin(inset: 100)
        previousButton.anchors.bottom.pin()
        previousButton.anchors.width.equal(100)
    }
    
    func configureNextButton() {
        nextButton.backgroundColor = .clear
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        
        playView.addSubview(nextButton)
        nextButton.anchors.trailing.pin()
        nextButton.anchors.top.pin(inset: 100)
        nextButton.anchors.bottom.pin()
        nextButton.anchors.width.equal(100)
    }
}
