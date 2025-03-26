import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

final class WinnerListCellController: NSObject {
    private var cell: WinnerListCell?
    
    private let viewModel: WinnerViewModel
    
    init(viewModel: WinnerViewModel) {
        self.viewModel = viewModel
    }
    
    private func releaseCell() {
        cell = nil
    }
}

extension WinnerListCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.setAnimatedSkeletonView(false)
        cell?.configure(with: viewModel)
        cell?.onReuse = { [weak self] in
            self?.releaseCell()
        }
        return cell!
    }
}
