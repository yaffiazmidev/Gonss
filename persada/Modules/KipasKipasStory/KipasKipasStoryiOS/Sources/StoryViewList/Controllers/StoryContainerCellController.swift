import UIKit
import KipasKipasShared
import KipasKipasStory

protocol StoryContainerCellControllerDelegate: AnyObject {
    func showUserStory(at position: StoryPosition)
    func showShare(viewModel: StoryItemViewModel, deleteAction: @escaping () -> Void)
    func showListViewers(viewModel: StoryItemViewModel, deleteAction: @escaping () -> Void)
    func showCameraGallery()
    func dismissStory()
    func showProfile(id: String)
}

final class StoryContainerCellController: NSObject {
    
    private let manager = StoriesManager.shared
    private let viewModel: StorySectionViewModel
    private var index: Int?
    
    private weak var delegate: StoryContainerCellControllerDelegate?
    private var cell: StoryContainerCell?
    
    init(
        viewModel: StorySectionViewModel,
        delegate: StoryContainerCellControllerDelegate
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    private func releaseCell() {
        cell = nil
    }
    
    private func cell(_ collectionView: UICollectionView, at index: Int) -> StoryCell? {
        let indexPath = IndexPath(item: index, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as? StoryContainerCell
        return cell?.collectionView.visibleCells.first as? StoryCell
    }
}

// MARK: UICollectionViewDataSource
extension StoryContainerCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        index = indexPath.item
        
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.onReuse = { [weak self] in
            self?.releaseCell()
        }
        cell?.showPreviousUserStory = { [weak self] in
            self?.delegate?.showUserStory(at: .previous(indexPath.previousItem))
        }
        cell?.showNextUserStory = { [weak self] in
            self?.delegate?.showUserStory(at: .next(indexPath.nextItem))
        }
        cell?.showShareSheet = { [weak self] story in
            self?.delegate?.showShare(
                viewModel: story.0,
                deleteAction: story.1
            )
        }
        cell?.showListViewers = { [weak self] story in
            self?.delegate?.showListViewers(
                viewModel: story.0,
                deleteAction: story.1
            )
        }
        cell?.showCameraGallery = { [weak self] in
            self?.delegate?.showCameraGallery()
        }
        
        cell?.dismissStory = { [weak self] in
            self?.delegate?.dismissStory()
        }
        cell?.showProfile = { [weak self] id in
            self?.delegate?.showProfile(id: id)
        }
        return cell!
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension StoryContainerCellController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? StoryContainerCell
        cell?.configure(with: manager.sections[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    /// Handling pausing segmented progress and set story has been viewed
    /// when user using scroll gesture to move between stories
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView,
              let index = index else {
            return
        }

        let xOffset = collectionView.contentOffset.x
        let width = collectionView.bounds.width
        let nextIndex = index + 1
        let previousIndex = index - 1
        
        let newIndex = xOffset / width
    
        /// Did scroll to right
        if newIndex == CGFloat(nextIndex) {
            let leftCell = cell(collectionView, at: index)
            leftCell?.cleanUp()
            
            let rightCell = cell(collectionView, at: index + 2)
            rightCell?.resetSegmentedView()
            
            /// Did scroll to left
        } else if newIndex == CGFloat(previousIndex) {
            let rightCell = cell(collectionView, at: index)
            rightCell?.cleanUp()
            
            let leftCell = cell(collectionView, at: index - 2)
            leftCell?.resetSegmentedView()
        }
    }
}
