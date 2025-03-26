import UIKit
import KipasKipasShared
import KipasKipasStory
import KipasKipasImage

protocol StoryListCellControllerDelegate: AnyObject {
    func showStory(
        at position: StoryPosition,
        isEdge: Bool
    )
    func showShare(
        viewModel: StoryItemViewModel,
        deleteAction: @escaping () -> Void
    )
    func showListViewers(
        viewModel: StoryItemViewModel,
        deleteAction: @escaping () -> Void
    )
    func showCamera()
    func dismiss()
    func showProfile(id: String)
}

enum StoryPosition {
    case previous(Int)
    case next(Int)
}

final class StoryListCellController: NSObject {
    
    private var cell: BaseStoryCell?
    
    private var section: StorySectionViewModel? {
        return manager.section(for: viewModel)
    }
    
    private var stories: [StoryItemViewModel] {
        return manager.section(for: viewModel)?.stories ?? []
    }
    
    private lazy var segmentedProgressView = SegmentedProgressView(frame: .init(
        origin: .init(x: 12, y: 0),
        size: .init(width: UIScreen.main.bounds.width - 24, height: 3)
    ))
    
    private let manager = StoriesManager.shared
    private let viewModel: StorySectionViewModel
    
    private weak var delegate: StoryListCellControllerDelegate?
    
    init(
        viewModel: StorySectionViewModel,
        delegate: StoryListCellControllerDelegate
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init()
        
        segmentedProgressView.dataSource = self
        segmentedProgressView.delegate = self
    }
    
    deinit {
        cell?.segmentedProgressView?.removeObserver()
    }
    
    private func showStory(at position: StoryPosition) {
        var index: Int
        
        switch position {
        case let .previous(previousIndex):
            index = previousIndex
        case let .next(nextIndex):
            index = nextIndex
        }
        
        let hasElementAtIndex = viewModel.stories.hasElement(at: index)
        delegate?.showStory(at: position, isEdge: hasElementAtIndex == false)
    }
    
    private func releaseCell() {
        cell?.cleanUp()
        cell = nil
    }
}

extension StoryListCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let story = stories[safe: indexPath.item] else {
            cell = collectionView.dequeueReusableCell(at: indexPath)
            return cell!
        }
        return createCell(
            collectionView,
            indexPath: indexPath,
            with: story
        )
    }
    
    private func createCell(
        _ collectionView: UICollectionView,
        indexPath: IndexPath,
        with viewModel: StoryItemViewModel
    ) -> UICollectionViewCell {
        
        let perspective = viewModel.perspective
                
        switch perspective {
        case .me:
            let cell: StoryMeCell = collectionView.dequeueReusableCell(at: indexPath)
            self.cell = cell
            
        case .friends:
            let cell: StoryFriendsCell = collectionView.dequeueReusableCell(at: indexPath)
            self.cell = cell
        }
        
        cell?.segmentedProgressView = segmentedProgressView
        cell?.configure(with: viewModel, index: indexPath.item)
        
        cell?.onReuse = { [weak self] in
            self?.releaseCell()
        }
        cell?.setViewed = { [weak self] in
            self?.updateViewed(at: indexPath.item)
        }
        cell?.onTapLike = { [weak self] isLiked in
            self?.updateLike(isLiked, at: indexPath.item)
        }
        cell?.previousButtonCallback = { [weak self, indexPath] in
            self?.showStory(at: .previous(indexPath.previousItem))
        }
        cell?.nextButtonCallback = { [weak self, indexPath] in
            self?.showStory(at: .next(indexPath.nextItem))
        }
        cell?.onTapShareButton = { [weak self] in
            self?.delegate?.showShare(
                viewModel: viewModel,
                deleteAction: { [weak self] in
                    self?.releaseCell()
                    self?.deleteStory(at: indexPath.item)
                })
        }
        cell?.onTapListViewers = { [weak self] in
            self?.delegate?.showListViewers(
                viewModel: viewModel, 
                deleteAction: { [weak self] in
                    self?.releaseCell()
                    self?.deleteStory(at: indexPath.item)
                })
        }
        cell?.onTapCamera = { [weak self] in
            self?.delegate?.showCamera()
        }
        cell?.onTapCloseButton = { [weak self] in
            self?.delegate?.dismiss()
        }
        cell?.onTapProfile = { [weak self] in
            self?.delegate?.showProfile(id: viewModel.account.id)
        }
        
        return cell!
    }
    
    // MARK: Update State
    private func updateLike(_ isLiked: Bool, at index: Int) {
        if var viewModel = section {
            viewModel.stories[index].isLiked = isLiked
            manager.setLike(
                section: viewModel,
                story: viewModel.stories[index]
            )
        }
    }
    
    private func updateViewed(at index: Int) {
        if var viewModel = section,
           viewModel.stories.hasElement(at: index) {
            viewModel.stories[index].isViewed = true
            manager.setViewed(
                section: viewModel,
                story: viewModel.stories[index]
            )
        }
    }
    
    private func deleteStory(at index: Int) {
        if var viewModel = section {
            let deletedStory = viewModel.stories.remove(at: index)
            manager.delete(
                section: viewModel,
                story: deletedStory
            )
            
            if viewModel.stories.hasElement(at: index) {
                showStory(at: .next(index))
            }
        }
    }
}

extension StoryListCellController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let story = viewModel.stories[indexPath.item]
        let photoURLs = [
            story.media.mediaURL,
            story.media.thumbnailURL,
            story.account.photoURL,
            story.firstViewerPhotoURL,
            story.secondViewerPhotoURL
        ].compactMap { $0}
        
        imagePrefetcher.startPrefetching(with: photoURLs)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? BaseStoryCell
        cell?.cleanUp()
        
        updateViewed(at: indexPath.item)
        imagePrefetcher.stopPrefetching()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension StoryListCellController: SegmentedProgressViewDataSource, SegmentedProgressViewDelegate {
    var numberOfSegments: Int {
        return stories.count
    }
    
    var segmentDuration: TimeInterval? {
        return cell?.playView.playDuration
    }
    
    func segmentedProgressView(completedAt index: Int, isLastIndex: Bool) {
        updateViewed(at: index)
        
        let nextIndex = index + 1
        showStory(at: .next(nextIndex))
    }
}
