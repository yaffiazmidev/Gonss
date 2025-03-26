import UIKit
import KipasKipasShared
import KipasKipasStory

final class StoryViewingListController: CollectionListController {
    
    private let storiesManager = StoriesManager.shared
    
    var showListViewers: Closure<(StoryItemViewModel, EmptyClosure)>?
    var showShareSheet: Closure<(StoryItemViewModel, EmptyClosure)>?
    var showCamera: EmptyClosure?
    var showProfile: Closure<String>?
    
    var seenStory: Closure<StorySeenRequest>?
    var likeStory: Closure<StoryLikeRequest>?
    var deleteStory: Closure<StoryDeleteRequest>?
    
    private let selectedId: String
    private let viewModels: [StorySectionViewModel]
    
    let seenAdapter = StorySeenViewAdapter()
    let likeAdapter = StoryLikeViewAdapter()
    let deleteAdapter = StoryDeleteViewAdapter()
    
    init(
        selectedId: String,
        viewModels: [StorySectionViewModel]
    ) {
        self.selectedId = selectedId
        self.viewModels = viewModels
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: VideoPlayerView.shouldResumeWhenVisible, object: nil)
        NotificationCenter.default.post(name: StoryPlayView.shouldResumeWhenVisible, object: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .night
        configureUI()
        super.viewDidLoad()
        
        set(viewModels)
    }
    
    deinit {
        StoriesManager.nullify()
        VideoPlayerManager.destroy()
        display(sections: [])
    }
    
    // MARK: Privates
    private func set(_ viewModels: [StorySectionViewModel]) {
        let controllers: [CollectionCellController] = viewModels.map { viewModel in
            let view = StoryContainerCellController(
                viewModel: viewModel,
                delegate: self
            )
            return CollectionCellController(id: viewModel.feedId, view)
        }
        
        let section = CollectionSectionController(
            cellControllers: controllers,
            sectionType: "LIST_STORY"
        )
        
        display(sections: [section])
        setSelected(viewModels)
        storiesManager.configure(viewModels, delegate: self)
    }
    
    private func setSelected(_ viewModels: [StorySectionViewModel]) {
        if let index = viewModels.firstIndex(where: { $0.feedId == selectedId }) {
            scrollTo(index)
        }
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let layout = AnimatedCollectionViewLayout()
        layout.animator = CubeAttributesAnimator(perspective: -1/200, totalAngle: .pi/12)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = .zero
        return layout
    }
    
    private func scrollTo(_ index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView.isPagingEnabled = false
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.collectionView.isPagingEnabled = true
    }
    
    private func pauseCurrentStory() {
        NotificationCenter.default.post(name: VideoPlayerView.shouldPausedWhenNotVisible, object: nil)
        NotificationCenter.default.post(name: StoryPlayView.shouldPausedWhenNotVisible, object: nil)
    }
}

extension StoryViewingListController: StoryContainerCellControllerDelegate {
    func showUserStory(at position: StoryPosition) {
        var index: Int
        var isPrevious: Bool
        
        switch position {
        case let .previous(previousIndex):
            index = previousIndex
            isPrevious = true
        case let .next(nextIndex):
            index = nextIndex
            isPrevious = false
        }
        
        if storiesManager.sections.hasElement(at: index) {
            scrollTo(index)
        } else {
            if !isPrevious {
                dismissStory()
            }
        }
    }
    
    func showShare(
        viewModel: StoryItemViewModel,
        deleteAction: @escaping () -> Void
    ) {
        showShareSheet?((viewModel, deleteAction))
        pauseCurrentStory()
    }
    
    func showListViewers(
        viewModel: StoryItemViewModel,
        deleteAction: @escaping () -> Void
    ) {
        showListViewers?((viewModel, deleteAction))
        pauseCurrentStory()
    }
  
    func showCameraGallery() {
        showCamera?()
        pauseCurrentStory()
    }
    
    func dismissStory() {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .init("storyDidBackFromViewing"), object: nil)
        }
    }
    
    func showProfile(id: String) {
        showProfile?(id)
        pauseCurrentStory()
    }
}

extension StoryViewingListController: StoriesManagerDelegate {
    func didUpdateLike(on story: StoryItemViewModel) {
        likeStory?(.init(
            storyId: story.id,
            likeStatus: story.isLiked ? .like : .unlike
        ))
    }
    
    func didUpdateViewed(on story: StoryItemViewModel) {
        seenStory?(.init(storyId: story.id))
    }
    
    func didDelete(for story: StoryItemViewModel, isEmpty: Bool) {
        deleteStory?(.init(
            id: story.id,
            feedId: story.feedId
        ))
        
        if storiesManager.sections.isEmpty {
            dismissStory()
            return
        }
        
        if isEmpty {
            set(storiesManager.sections)
        } else {
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
        }
    }
}

// MARK: UI
private extension StoryViewingListController {
    func configureUI() {
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .night
        collectionView.setCollectionViewLayout(makeLayout(), animated: true)
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .init(rawValue: 0.9)
        collectionView.registerCell(StoryContainerCell.self)
        
        collectionView.anchors.top.pin()
        collectionView.anchors.edges.pin(axis: .horizontal)
        collectionView.anchors.bottom.pin()
    }
}
