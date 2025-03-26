import UIKit
import KipasKipasShared
import KipasKipasStory

final class StoryContainerCell: UICollectionViewCell {
    
    lazy var collectionView: CollectionListView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = .zero
        
        return CollectionListView(
            frame: .zero,
            collectionViewLayout: layout
        )
    }()
    
    var onReuse: EmptyClosure?
    var showPreviousUserStory: EmptyClosure?
    var showNextUserStory: EmptyClosure?
    var showCameraGallery: EmptyClosure?
    var showShareSheet: Closure<(StoryItemViewModel, EmptyClosure)>?
    var showListViewers: Closure<(StoryItemViewModel, EmptyClosure)>?
    var showProfile: Closure<String>?
    
    var dismissStory: EmptyClosure?
    
    private var sectionCount: Int = 0
    
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
    
    private func configureData(_ viewModel: StorySectionViewModel) {
        let controllers: [CollectionCellController] = viewModel.stories.map { model in
            switch model.type {
            case .post:
                let view = StoryListCellController(
                    viewModel: viewModel,
                    delegate: self
                )
                return CollectionCellController(view)
            case .repost:
                let view = StoryListRepostCellController(
                    viewModel: viewModel,
                    delegate: self
                )
                return CollectionCellController(view)
            }
        }
        
        let section = CollectionSectionController(
            cellControllers: controllers,
            sectionType: viewModel.feedId
        )
        
        collectionView.display(sections: [section])
        scrollToHasNotViewedStory(viewModel)
        
        sectionCount = viewModel.stories.count
    }
    
    private func scrollTo(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    private func scrollToHasNotViewedStory(_ viewModel: StorySectionViewModel) {
        guard sectionCount == 0 else { return }
        
        if viewModel.stories.count > 0 {
            if viewModel.stories.allSatisfy({ $0.isViewed }) {
                scrollTo(index: 0)
            } else if let index = viewModel.stories.lastIndex(where: { $0.isViewed == true }), index > 0 {
                scrollTo(index: index)
            }
        }
    }
    
    // MARK: API
    func configure(with viewModel: StorySectionViewModel) {
        configureData(viewModel)
    }
}

extension StoryContainerCell: StoryListCellControllerDelegate {
    func showStory(at position: StoryPosition, isEdge: Bool) {
        switch (position, isEdge) {
        case (.previous(let previousIndex), false):
            scrollTo(index: previousIndex)
            collectionView.reloadData()
            
        case (.next(let nextIndex), false):
            scrollTo(index: nextIndex)
            collectionView.reloadData()
            
        case (.previous, true):
            showPreviousUserStory?()
            
        case (.next, true):
            showNextUserStory?()
        }
    }
    
    func showShare(viewModel: StoryItemViewModel, deleteAction: @escaping () -> Void) {
        showShareSheet?((viewModel, deleteAction))
    }
    
    func showListViewers(viewModel: StoryItemViewModel, deleteAction: @escaping () -> Void) {
        showListViewers?((viewModel, deleteAction))
    }
    
    func dismiss() {
        dismissStory?()
    }
    
    func showCamera() {
        showCameraGallery?()
    }
    
    func showProfile(id: String) {
        showProfile?(id)
    }
}

// MARK: UI
private extension StoryContainerCell {
    func configureUI() {
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .night
        
        collectionView.registerCell(BaseStoryCell.self)
        collectionView.registerCell(StoryMeCell.self)
        collectionView.registerCell(StoryMeRepostCell.self)
        collectionView.registerCell(StoryFriendsCell.self)
        collectionView.registerCell(StoryFriendsRepostCell.self)
        
        contentView.addSubview(collectionView)
        collectionView.anchors.edges.pin()
    }
}
