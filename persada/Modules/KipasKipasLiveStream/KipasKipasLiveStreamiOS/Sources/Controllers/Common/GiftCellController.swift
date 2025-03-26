import UIKit
import Combine
import KipasKipasShared
import KipasKipasLiveStream

final class GiftCellController: CellController {
    
    private let viewModel: LiveGift
    private let selection: (LiveGift) -> Void
    
    override var isSelected: Bool {
        didSet {
            cell?.setSelected = isSelected
        }
    }
    
    override var isLoading: Bool {
        didSet {
            cell?.isLoading = isLoading
        }
    }
    
    private var schedulerCancellable: AnyCancellable?
    
    init(
        viewModel: LiveGift,
        selection: @escaping (LiveGift) -> Void
    ) {
        self.viewModel = viewModel
        self.selection = selection
    }
    
    private var cell: GiftCell?
    
    override func view(_ collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.giftImageView.setImage(with: viewModel.giftURL)
        cell?.giftNameLabel.text = viewModel.title
        cell?.coinView.coinAmountLabel.text = String(viewModel.price ?? 0)
        cell?.setSelected = isSelected
        cell?.isLoading = isLoading
        
        return cell!
    }
    
    override func select() {
        if isSelected {
            self.selection(viewModel)
            self.isLoading = true
            self.startCountdown()
        }
        isSelected = true
        cell?.sendButton.onTap(action: { [weak self, viewModel] in
            self?.selection(viewModel)
            self?.isLoading = true
            self?.startCountdown()
        })
    }
    
    override func deselect() {
        isSelected = false
        isLoading = false
        stopCountdown()
    }
    
    private func startCountdown() {
        schedulerCancellable = CountDownTimer(duration: 5, repeats: false)
            .handleEvents(receiveOutput: { [weak self] remaining in
                if remaining.totalSeconds < 0 {
                    self?.stopCountdown()
                }
            })
            .sink(receiveValue: { [weak self] remaining in
                guard let self = self else { return }
                isLoading = isLoading && remaining.seconds > 0
            })
    }
    
    private func stopCountdown() {
        schedulerCancellable?.cancel()
        schedulerCancellable = nil
    }
}
