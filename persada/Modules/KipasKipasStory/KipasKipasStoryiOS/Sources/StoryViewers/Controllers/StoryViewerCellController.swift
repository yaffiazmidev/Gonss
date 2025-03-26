import UIKit
import KipasKipasShared
import KipasKipasStory

protocol StoryViewerCellControllerDelegate: AnyObject {
    func didTapFollow(viewer: inout StoryViewerViewModel)
    func didTapSendMessage(viewer: StoryViewerViewModel)
    func didTapProfile(viewer: StoryViewerViewModel)
}

final class StoryViewerCellController: NSObject {
    
    private var cell: StoryViewerCell?
    
    private let viewModel: StoryViewerViewModel
    private let delegate: StoryViewerCellControllerDelegate
    
    init(
        viewModel: StoryViewerViewModel,
        delegate: StoryViewerCellControllerDelegate
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    private func releaseCell() {
        cell = nil
    }
}

extension StoryViewerCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.configure(with: viewModel)
        
        var viewModel = viewModel
        
        cell?.onReuse = { [weak self] in
            self?.releaseCell()
        }
        cell?.onTapFollow = { [weak self] in
            self?.delegate.didTapFollow(viewer: &viewModel)
        }
        cell?.onTapSendMessage = { [weak self] in
            self?.delegate.didTapSendMessage(viewer: viewModel)
        }
        cell?.onTapProfile = { [weak self] in
            self?.delegate.didTapProfile(viewer: viewModel)
        }
        return cell!
    }
}
